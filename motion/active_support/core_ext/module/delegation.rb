require __ORIGINAL__

class Module
  # Overwrite original
  # Rewrite not to use string eval
  def delegate(*methods)
    options = methods.pop
    unless options.is_a?(Hash) && to = options[:to]
      raise ArgumentError, 'Delegation needs a target. Supply an options hash with a :to key as the last argument (e.g. delegate :hello, to: :greeter).'
    end

    prefix, allow_nil = options.values_at(:prefix, :allow_nil)
    unguarded = !allow_nil

    if prefix == true && to =~ /^[^a-z_]/
      raise ArgumentError, 'Can only automatically set the delegation prefix when delegating to a method.'
    end

    method_prefix = \
      if prefix
        "#{prefix == true ? to : prefix}_"
      else
        ''
      end

    reference, *hierarchy = to.to_s.split('.')
    entry = resolver =
      case reference
      when 'self'
        ->(_self) { _self }
      when /^@@/
        ->(_self) { _self.class.class_variable_get(reference) }
      when /^@/
        ->(_self) { _self.instance_variable_get(reference) }
      when /^[A-Z]/
        ->(_self) { if reference.to_s =~ /::/ then reference.constantize else _self.class.const_get(reference) end }
      else
        ->(_self) { _self.send(reference) }
      end
    resolver = ->(_self) { hierarchy.reduce(entry.call(_self)) { |obj, method| obj.public_send(method) } } unless hierarchy.empty?

    methods.each do |method|
      module_exec do
        # def customer_name(*args, &block)
        #   begin
        #     if unguarded || client || client.respond_to?(:name)
        #       client.name(*args, &block)
        #     end
        #   rescue client.nil? && NoMethodError
        #     raise "..."
        #   end
        # end
        define_method("#{method_prefix}#{method}") do |*args, &block|
          target = resolver.call(self)
          if unguarded || target || target.respond_to?(method)
            begin
              target.public_send(method, *args, &block)
            rescue target.nil? && NoMethodError # only rescue NoMethodError when target is nil
              raise "#{self}##{method_prefix}#{method} delegated to #{to}.#{method}, but #{to} is nil: #{self.inspect}"
            end
          end
        end
      end
    end
  end
end

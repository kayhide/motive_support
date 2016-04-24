require __ORIGINAL__

module ActiveSupport
  module Inflector
    # raise-rescue does not work properly on repl.

    # def safe_constantize(camel_cased_word)
    #   constantize(camel_cased_word)
    # rescue NameError => e
    #   raise if e.name && !(camel_cased_word.to_s.split("::").include?(e.name.to_s) ||
    #     e.name.to_s == camel_cased_word.to_s)
    # rescue ArgumentError => e
    #   raise unless e.message =~ /not missing constant #{const_regexp(camel_cased_word)}\!$/
    # end
    def safe_constantize(camel_cased_word)
      names = camel_cased_word.split('::')

      # Trigger a built-in NameError exception including the ill-formed constant in the message.
      return if names.empty?

      # Remove the first blank element in case of '::ClassName' notation.
      names.shift if names.size > 1 && names.first.empty?

      names.inject(Object) do |constant, name|
        return unless name =~ /\A[A-Z]\w*\z/
        return unless constant.const_defined?(name)

        if constant == Object
          constant.const_get(name)
        else
          candidate = constant.const_get(name)
          next candidate if constant.const_defined?(name, false)
          next candidate unless Object.const_defined?(name)

          # Go down the ancestors to check if it is owned directly. The check
          # stops when we reach Object or the end of ancestors tree.
          constant = constant.ancestors.inject do |const, ancestor|
            break const    if ancestor == Object
            break ancestor if ancestor.const_defined?(name, false)
            const
          end

          return unless constant.const_defined?(name, false)

          # owner is in Object, so raise
          constant.const_get(name, false)
        end
      end
    end
  end
end

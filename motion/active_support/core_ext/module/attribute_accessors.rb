require __ORIGINAL__

class Module
  # Overwrite original
  # Rewrite not to use string eval
  def mattr_reader(*syms, &proc)
    receiver = self
    options = syms.extract_options!
    syms.each do |sym|
      raise NameError.new('invalid attribute name') unless sym =~ /^[_A-Za-z]\w*$/
      class_exec do
        unless class_variable_defined?("@@#{sym}")
          class_variable_set("@@#{sym}", nil)
        end

        define_singleton_method sym do
          class_variable_get("@@#{sym}")
        end
      end

      unless options[:instance_reader] == false || options[:instance_accessor] == false
        class_exec do
          define_method sym do
            receiver.class_variable_get("@@#{sym}")
          end
        end
      end
      class_variable_set("@@#{sym}", proc.call) if proc
    end
  end
  alias :cattr_reader :mattr_reader

  # Overwrite original
  # Rewrite not to use string eval
  def mattr_writer(*syms, &proc)
    receiver = self
    options = syms.extract_options!
    syms.each do |sym|
      raise NameError.new('invalid attribute name') unless sym =~ /^[_A-Za-z]\w*$/
      class_exec do
        define_singleton_method "#{sym}=" do |obj|
          class_variable_set("@@#{sym}", obj)
        end
      end

      unless options[:instance_writer] == false || options[:instance_accessor] == false
        class_exec do
          define_method "#{sym}=" do |obj|
            receiver.class_variable_set("@@#{sym}", obj)
          end
        end
      end
      send("#{sym}=", proc.call) if proc
    end
  end
  alias :cattr_writer :mattr_writer
end

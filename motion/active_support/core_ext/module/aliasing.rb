require __ORIGINAL__

class Module
  # Overwrite original
  # Rewrite not to use string eval
  def alias_attribute(new_name, old_name)
    module_exec do
      define_method(new_name) { self.send(old_name) }
      define_method("#{new_name}?") { self.send("#{old_name}?") }
      define_method("#{new_name}=") { |v| self.send("#{old_name}=", v) }
    end
  end
end

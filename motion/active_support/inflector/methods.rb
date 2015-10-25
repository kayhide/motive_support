require __ORIGINAL__

module ActiveSupport
  module Inflector
    # Overwrite original
    # NameError#name always returns 'NameError'
    def safe_constantize(camel_cased_word)
      constantize(camel_cased_word)
    rescue NameError => e
      raise unless e.message =~ /(uninitialized constant|wrong constant name) (#{const_regexp(camel_cased_word.to_s)}|#{camel_cased_word.to_s.split("::").map{|s| const_regexp(s)}.join('|')})$/
    rescue ArgumentError => e
      raise unless e.message =~ /not missing constant #{const_regexp(camel_cased_word)}\!$/
    end
  end
end

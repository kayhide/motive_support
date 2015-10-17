Module.new do
  def use_locales locales
    before do
      @_original_locales = I18n.available_locales
      I18n.available_locales = locales
    end

    after do
      I18n.available_locales = @_original_locales
    end
  end

  Bacon::Context.send :include, self
end

Module.new do
  def use_locales locales
    original_locales = nil
    before do
      original_locales = I18n.available_locales
      I18n.available_locales = locales
    end

    after do
      I18n.available_locales = original_locales
    end
  end

  Bacon::Context.send :include, self
end

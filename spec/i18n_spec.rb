describe I18n do
  use_locales [:en, :ja]

  before do
    %w(ja fr).each do |lang|
      path = "locale/spec/#{lang}.yml"
      unless I18n.load_path.include? path
        I18n.load_path << path
      end
    end
    I18n.locale = :en
  end

  describe '#translate' do
    it 'returns translated strings' do
      I18n.translate('date.abbr_day_names')
        .should == %w(Sun Mon Tue Wed Thu Fri Sat)
    end

    it 'works with ja lang' do
      I18n.locale = :ja
      I18n.translate('date.abbr_day_names')
        .should == %w(日 月 火 水 木 金 土)
    end
  end

  describe '#localize' do
    it 'returns localized strings' do
      I18n.localize(Time.utc(2015, 10, 16, 21, 59, 28), format: :long)
        .should == 'October 16, 2015 21:59'
    end

    it 'works with ja lang' do
      I18n.available_locales = [:en, :ja]
      I18n.locale = :ja
      I18n.localize(Time.utc(2015, 10, 16, 21, 59, 28), format: :long)
        .should == '2015年10月16日(金) 21時59分28秒 +0000'
    end
  end
end

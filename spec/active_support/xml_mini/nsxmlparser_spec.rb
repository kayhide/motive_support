describe "XmlMini_NSXMLParser" do
  describe '.parse' do
    it 'parses xml' do
      xml = <<-XML
        <root>
          good
          <products>
            hello everyone
          </products>
          morning
        </root>
      XML

      doc = ActiveSupport::XmlMini_NSXMLParser.parse(xml)
      doc['root']['__content__'].should.match(/good\s+morning/)
      doc['root']['products']['__content__'].should.match(/hello everyone/)
    end
  end
end

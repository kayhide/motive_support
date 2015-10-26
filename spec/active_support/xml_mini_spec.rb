describe "XmlMini" do
  describe '.rename_key' do
    it 'renames key dasherizes by default' do
      ActiveSupport::XmlMini.rename_key("my_key").should == 'my-key'
    end

    it 'renames key dasherizes with dasherize true' do
      ActiveSupport::XmlMini.rename_key("my_key", :dasherize => true).should == 'my-key'
    end

    it 'renames key does nothing with dasherize false' do
      ActiveSupport::XmlMini.rename_key("my_key", :dasherize => false).should == 'my_key'
    end

    it 'renames key camelizes with camelize true' do
      ActiveSupport::XmlMini.rename_key("my_key", :camelize => true).should == 'MyKey'
    end

    it 'renames key lower camelizes with camelize lower' do
      ActiveSupport::XmlMini.rename_key("my_key", :camelize => :lower).should == 'myKey'
    end

    it 'renames key lower camelizes with camelize upper' do
      ActiveSupport::XmlMini.rename_key("my_key", :camelize => :upper).should == 'MyKey'
    end

    it 'renames key does not dasherize leading underscores' do
      ActiveSupport::XmlMini.rename_key("_id").should == '_id'
    end

    it 'renames key with leading underscore dasherizes interior underscores' do
      ActiveSupport::XmlMini.rename_key("_my_key").should == '_my-key'
    end

    it 'renames key does not dasherize trailing underscores' do
      ActiveSupport::XmlMini.rename_key("id_").should == 'id_'
    end

    it 'renames key with trailing underscore dasherizes interior underscores' do
      ActiveSupport::XmlMini.rename_key("my_key_").should == 'my-key_'
    end

    it 'renames key does not dasherize multiple leading underscores' do
      ActiveSupport::XmlMini.rename_key("__id").should == '__id'
    end

    it 'renames key does not dasherize multiple trailing underscores' do
      ActiveSupport::XmlMini.rename_key("id__").should == 'id__'
    end
  end

  describe '.to_tag' do
    def assert_xml(xml)
      @options[:builder].target!.should == xml
    end

    before do
      @xml = ActiveSupport::XmlMini
      @options = {:skip_instruct => true, :builder => Builder::XmlMarkup.new(indent: 0)}
    end

    it "accepts a callable object and passes options with the builder" do
      @xml.to_tag(:some_tag, lambda {|o| o[:builder].br }, @options)
      assert_xml "<br/>"
    end

    it "accepts a callable object and passes options and tag name" do
      @xml.to_tag(:tag, lambda {|o, t| o[:builder].b(t) }, @options)
      assert_xml "<b>tag</b>"
    end

    it "accepts an object responding to #to_xml and passes the options, where :root is key" do
      obj = Object.new
      obj.instance_eval do
        def to_xml(options) options[:builder].yo(options[:root].to_s) end
      end

      @xml.to_tag(:tag, obj, @options)
      assert_xml "<yo>tag</yo>"
    end

    it "accepts arbitrary objects responding to #to_str" do
      @xml.to_tag(:b, "Howdy", @options)
      assert_xml "<b>Howdy</b>"
    end

    it "uses the type value in the options hash" do
      @xml.to_tag(:b, "blue", @options.merge(type: 'color'))
      assert_xml( "<b type=\"color\">blue</b>" )
    end

    it "accepts symbol types" do
      @xml.to_tag(:b, :name, @options)
      assert_xml( "<b type=\"symbol\">name</b>" )
    end

    it "accepts boolean types" do
      @xml.to_tag(:b, true, @options)
      assert_xml( "<b type=\"boolean\">true</b>")
    end

    it "accepts float types" do
      @xml.to_tag(:b, 3.14, @options)
      assert_xml( "<b type=\"float\">3.14</b>")
    end

    it "accepts decimal types" do
      @xml.to_tag(:b, ::BigDecimal.new("1.2"), @options)
      assert_xml( "<b type=\"decimal\">1.2</b>")
    end

    it "accepts date types" do
      @xml.to_tag(:b, Date.new(2001,2,3), @options)
      assert_xml( "<b type=\"date\">2001-02-03</b>")
    end

    # it "accepts datetime types" do
    #   @xml.to_tag(:b, DateTime.new(2001,2,3,4,5,6,'+7'), @options)
    #   assert_xml( "<b type=\"dateTime\">2001-02-03T04:05:06+07:00</b>")
    # end

    it "accepts time types" do
      @xml.to_tag(:b, Time.new(1993, 02, 24, 12, 0, 0, "+09:00"), @options)
      assert_xml( "<b type=\"dateTime\">1993-02-24T12:00:00+09:00</b>")
    end

    it "accepts array types" do
      @xml.to_tag(:b, ["first_name", "last_name"], @options)
      assert_xml( "<b type=\"array\"><b>first_name</b><b>last_name</b></b>" )
    end

    it "accepts hash types" do
      @xml.to_tag(:b, { first_name: "Bob", last_name: "Marley" }, @options)
      assert_xml( "<b><first-name>Bob</first-name><last-name>Marley</last-name></b>" )
    end

    it "does not add type when skip types option is set" do
      @xml.to_tag(:b, "Bob", @options.merge(skip_types: 1))
      assert_xml( "<b>Bob</b>" )
    end

    it "dasherizes the space when passed a string with spaces as a key" do
      @xml.to_tag("New   York", 33, @options)
      assert_xml "<New---York type=\"integer\">33</New---York>"
    end

    it "dasherizes the space when passed a symbol with spaces as a key" do
      @xml.to_tag(:"New   York", 33, @options)
      assert_xml "<New---York type=\"integer\">33</New---York>"
    end
  end

  describe '.with_backend' do
    module REXML; end
    module LibXML end
    module Nokogiri end

    before do
      @xml, @default_backend = ActiveSupport::XmlMini, ActiveSupport::XmlMini.backend
    end

    after do
      ActiveSupport::XmlMini.backend = @default_backend
    end

    it "switches backend and then switch back" do
      @xml.backend = REXML
      @xml.with_backend(LibXML) do
        @xml.backend.should == LibXML
        @xml.with_backend(Nokogiri) do
          @xml.backend.should == Nokogiri
        end
        @xml.backend.should == LibXML
      end
      @xml.backend.should == REXML
    end

    it "switches inside .with_backend block" do
      @xml.with_backend(LibXML) do
        @xml.backend = REXML
        @xml.backend.should == REXML
      end
      @xml.backend.should == REXML
    end

    describe 'with thread' do
      it "is thread-safe" do
        @xml.backend = REXML
        t = Thread.new do
          @xml.with_backend(LibXML) { sleep 1 }
        end
        sleep 0.1 while t.status != "sleep"

        # We should get `old_backend` here even while another
        # thread is using `new_backend`.
        @xml.backend.should == REXML
      end

      it "is thread-safe when nested" do
        @xml.with_backend(REXML) do
          t = Thread.new do
            @xml.with_backend(LibXML) { sleep 1 }
          end
          sleep 0.1 while t.status != "sleep"

          @xml.backend.should == REXML
        end
      end
    end
  end

  describe 'parsing' do
    before do
      @parsing = ActiveSupport::XmlMini::PARSING
    end

    it 'works with symbol' do
      parser = @parsing['symbol']
      parser.call('symbol').should == :symbol
      parser.call(:symbol).should == :symbol
      parser.call(123).should == :'123'
      lambda { parser.call(Date.new(2013,11,12,02,11)) }.should.raise ArgumentError
    end

    it 'works with date' do
      parser = @parsing['date']
      parser.call("2013-11-12T0211Z").should == Date.new(2013,11,12)
      lambda { parser.call(1384190018) }.should.raise TypeError
      lambda { parser.call("not really a date") }.should.raise ArgumentError
    end

    it 'works with datetime' do
      parser = @parsing['datetime']
      parser.call("2013-11-12T02:11:00Z").should == Time.new(2013,11,12,02,11,00,0)
      # parser.call("2013-11-12T0211Z").should == DateTime.new(2013,11,12)
      # parser.call("2013-11-12T02:11Z").should == DateTime.new(2013,11,12,02,11)
      # parser.call("2013-11-12T11:11+9").should == DateTime.new(2013,11,12,02,11)
      lambda { parser.call("1384190018") }.should.raise ArgumentError
    end

    it 'works with integer' do
      parser = @parsing['integer']
      parser.call(123).should == 123
      parser.call(123.003).should == 123
      parser.call("123").should == 123
      parser.call("").should == 0
      lambda { parser.call(Date.new(2013,11,12,02,11)) }.should.raise ArgumentError
    end

    it 'works with float' do
      parser = @parsing['float']
      parser.call("123").should == 123
      parser.call("123.003").should == 123.003
      parser.call("123,003").should == 123.0
      parser.call("").should == 0.0
      parser.call(123).should == 123
      parser.call(123.05).should == 123.05
      lambda { parser.call(Date.new(2013,11,12,02,11)) }.should.raise ArgumentError
    end

    it 'works with decimal' do
      parser = @parsing['decimal']
      parser.call("123").should == 123
      parser.call("123.003").should == 123.003
      parser.call("123,003").should == 123.0
      # parser.call("").should == 0.0
      parser.call(123).should == 123
      # lambda { parser.call(123.04) }.should.raise ArgumentError
      lambda { parser.call(Date.new(2013,11,12,02,11)) }.should.raise ArgumentError
    end

    it 'works with boolean' do
      parser = @parsing['boolean']
      [1, true, "1"].each do |value|
        parser.call(value).should.be.true
      end

      [0, false, "0"].each do |value|
        parser.call(value).should.be.false
      end
    end

    it 'works with string' do
      parser = @parsing['string']
      parser.call(123).should == "123"
      parser.call("123").should == "123"
      parser.call("[]").should == "[]"
      parser.call([]).should == "[]"
      parser.call({}).should == "{}"
      lambda { parser.call(Date.new(2013,11,12,02,11)) }.should.raise ArgumentError
    end

    it 'works with yaml' do
      yaml = <<YAML
product:
  - sku         : BL394D
    quantity    : 4
    description : Basketball
YAML
      expected = {
        "product"=> [
          {"sku"=>"BL394D", "quantity"=>4, "description"=>"Basketball"}
        ]
      }
      parser = @parsing['yaml']
      parser.call(yaml).should == expected
      parser.call({1 => 'test'}).should == ({1 => 'test'})
      # parser.call("{1 => 'test'}").should == ({"1 => 'test'"=>nil})
    end

    it 'works with base64Binary and binary' do
      base64 = <<BASE64
TWFuIGlzIGRpc3Rpbmd1aXNoZWQsIG5vdCBvbmx5IGJ5IGhpcyByZWFzb24sIGJ1dCBieSB0aGlz
IHNpbmd1bGFyIHBhc3Npb24gZnJvbSBvdGhlciBhbmltYWxzLCB3aGljaCBpcyBhIGx1c3Qgb2Yg
dGhlIG1pbmQsIHRoYXQgYnkgYSBwZXJzZXZlcmFuY2Ugb2YgZGVsaWdodCBpbiB0aGUgY29udGlu
dWVkIGFuZCBpbmRlZmF0aWdhYmxlIGdlbmVyYXRpb24gb2Yga25vd2xlZGdlLCBleGNlZWRzIHRo
ZSBzaG9ydCB2ZWhlbWVuY2Ugb2YgYW55IGNhcm5hbCBwbGVhc3VyZS4=
BASE64
      expected_base64 = <<EXPECTED
Man is distinguished, not only by his reason, but by this singular passion from
other animals, which is a lust of the mind, that by a perseverance of delight
in the continued and indefatigable generation of knowledge, exceeds the short
vehemence of any carnal pleasure.
EXPECTED

      parser = @parsing['base64Binary']
      parser.call(base64).should == expected_base64.gsub(/\n/," ").strip
      parser.call("NON BASE64 INPUT")

      parser = @parsing['binary']
      parser.call(base64, 'encoding' => 'base64').should == expected_base64.gsub(/\n/," ").strip
      parser.call("IGNORED INPUT", {}).should == "IGNORED INPUT"
    end
  end
end

describe 'JSON::Encoding' do
  before do
    @_old_escape_html_entities_in_json = ActiveSupport.escape_html_entities_in_json
    @_old_use_standard_json_time_format = ActiveSupport.use_standard_json_time_format
  end

  after do
    ActiveSupport.escape_html_entities_in_json = @_old_escape_html_entities_in_json
    ActiveSupport.use_standard_json_time_format = @_old_use_standard_json_time_format
  end

  JSONTest::EncodingTestCases.each do |desc, tests|
    describe desc do
      it 'works' do
        ActiveSupport.escape_html_entities_in_json  = !!(desc !~ /^Standard/)
        ActiveSupport.use_standard_json_time_format = !!(desc =~ /^Standard/)
        tests.each do |pair|
          sorted_json(ActiveSupport::JSON.encode(pair.first)).should == pair.last
        end
      end
    end
  end

  it 'encodes Process::Status' do
    # There doesn't seem to be a good way to get a handle on a Process::Status object without actually
    # creating a child process, hence this to populate $?
    # system("not_a_real_program_#{SecureRandom.hex}")
    system("not_a_real_program_#{Time.now.to_i}")
    ActiveSupport::JSON.encode($?).should == %({"exitstatus":#{$?.exitstatus},"pid":#{$?.pid}})
  end

  it 'encodes hash' do
    ActiveSupport::JSON.encode(:a => :b).should == %({\"a\":\"b\"})
    ActiveSupport::JSON.encode('a' => 1).should == %({\"a\":1})
    ActiveSupport::JSON.encode('a' => [1,2]).should == %({\"a\":[1,2]})
    ActiveSupport::JSON.encode(1 => 2).should == %({"1":2})

    sorted_json(ActiveSupport::JSON.encode(:a => :b, :c => :d)).should == %({\"a\":\"b\",\"c\":\"d\"})
  end

  it 'escapes html entities' do
    ActiveSupport.escape_html_entities_in_json = true
    ActiveSupport::JSON.encode("<>").should == "\"\\u003c\\u003e\""
    ActiveSupport::JSON.encode("<>" => "<>").should == "{\"\\u003c\\u003e\":\"\\u003c\\u003e\"}"
  end

  it 'encodes utf8 string properly' do
    result = ActiveSupport::JSON.encode('€2.99')
    result.should == '"€2.99"'
    result.encoding.should == Encoding::UTF_8

    result = ActiveSupport::JSON.encode('✎☺')
    result.should == '"✎☺"'
    result.encoding.should == Encoding::UTF_8
  end

  it 'encodes wide utf8 chars' do
    w = '𠜎'
    result = ActiveSupport::JSON.encode(w)
    result.should == '"𠜎"'
  end

  it 'roundtrips wide utf8' do
    hash = { string: "𐒑" }
    json = ActiveSupport::JSON.encode(hash)
    decoded_hash = ActiveSupport::JSON.decode(json)
    decoded_hash['string'].should == "𐒑"
  end

  it 'quates hash key identifiers' do
    values = {0 => 0, 1 => 1, :_ => :_, "$" => "$", "a" => "a", :A => :A, :A0 => :A0, "A0B" => "A0B"}
    object_keys(ActiveSupport::JSON.encode(values)).should == %w( "$" "A" "A0" "A0B" "_" "a" "0" "1" ).sort
  end

  it 'filters key with only' do
    ActiveSupport::JSON.encode({'a' => 1, :b => 2, :c => 3}, :only => 'a').should == %({"a":1})
  end

  it 'filters key with except' do
    ActiveSupport::JSON.encode({'foo' => 'bar', :b => 2, :c => 3}, :except => ['foo', :c]).should == %({"b":2})
  end

  it 'includes local offset' do
    with_standard_json_time_format(true) do
      with_env_tz 'US/Eastern' do
        ActiveSupport::JSON.encode(Time.local(2005,2,1,15,15,10)).should == %("2005-02-01T15:15:10.000-05:00")
      end
    end
  end

  it 'encodes time' do
    with_standard_json_time_format(false) do
      { :time => Time.utc(2009) }.to_json.should == '{"time":"2009/01/01 00:00:00 +0000"}'
    end
  end

  it 'encodes nested hash with float' do
    lambda {
      hash = {
        "CHI" => {
          :display_name => "chicago",
          :latitude => 123.234
        }
      }
      ActiveSupport::JSON.encode(hash)
    }.should.not.raise
  end

  it 'encodes hashlike with options' do
    h = JSONTest::Hashlike.new
    json = h.to_json :only => [:foo]

    JSON.parse(json).should == {"foo"=>"hello"}
  end

  it 'encodes object with options' do
    obj = Object.new
    obj.instance_variable_set :@foo, "hello"
    obj.instance_variable_set :@bar, "world"
    json = obj.to_json :only => ["foo"]

    JSON.parse(json).should == {"foo"=>"hello"}
  end

  it 'encodes struct with options' do
    struct = Struct.new(:foo, :bar).new
    struct.foo = "hello"
    struct.bar = "world"
    json = struct.to_json :only => [:foo]

    JSON.parse(json).should == {"foo"=>"hello"}
  end

  describe 'with Hash' do
    it 'passes encoding options to children in as_json' do
      person = {
        :name => 'John',
        :address => {
          :city => 'London',
          :country => 'UK'
        }
      }
      json = person.as_json :only => [:address, :city]

      json.should == { 'address' => { 'city' => 'London' }}
    end
  end

  describe 'with Array' do
    it 'passes encoding options to children in as_json' do
      people = [
        { :name => 'John', :address => { :city => 'London', :country => 'UK' }},
        { :name => 'Jean', :address => { :city => 'Paris' , :country => 'France' }}
      ]
      json = people.as_json :only => [:address, :city]
      expected = [
        { 'address' => { 'city' => 'London' }},
        { 'address' => { 'city' => 'Paris' }}
      ]

      json.should == expected
    end
  end

  describe 'with Enumerable' do
    class People
      include Enumerable

      def people
        [
          { :name => 'John', :address => { :city => 'London', :country => 'UK' }},
          { :name => 'Jean', :address => { :city => 'Paris' , :country => 'France' }}
        ]
      end

      def each(*, &blk)
        if blk
          people.each &blk
        else
          people.each
        end
      end
    end

    it 'generates json' do
      json = People.new.as_json :only => [:address, :city]
      expected = [
        { 'address' => { 'city' => 'London' }},
        { 'address' => { 'city' => 'Paris' }}
      ]

      json.should == expected
    end

    it 'passes encoding options to children in as_json' do
      json = People.new.each.as_json :only => [:address, :city]
      expected = [
        { 'address' => { 'city' => 'London' }},
        { 'address' => { 'city' => 'Paris' }}
      ]

      json.should == expected
    end
  end

  describe 'with Object with #as_json' do
    class CustomWithOptions
      attr_accessor :foo, :bar

      def as_json(options={})
        options[:only] = %w(foo bar)
        super(options)
      end
    end

    it 'does not keep options around with Hash' do
      f = CustomWithOptions.new
      f.foo = "hello"
      f.bar = "world"

      hash = {"foo" => f, "other_hash" => {"foo" => "other_foo", "test" => "other_test"}}
      ActiveSupport::JSON.decode(hash.to_json)
        .should == {
        "foo"=>{"foo"=>"hello","bar"=>"world"},
        "other_hash" => {"foo"=>"other_foo","test"=>"other_test"}}
    end

    it 'does not keep options around with Array' do
      f = CustomWithOptions.new
      f.foo = "hello"
      f.bar = "world"

      array = [f, {"foo" => "other_foo", "test" => "other_test"}]
      ActiveSupport::JSON.decode(array.to_json)
        .should == [
        {"foo"=>"hello","bar"=>"world"},
        {"foo"=>"other_foo","test"=>"other_test"}]
    end
  end

  describe 'options' do
    class OptionsTest
      def as_json(options = :default)
        options
      end
    end

    it 'works with Hash' do
      json = { foo: OptionsTest.new }.as_json
      json.should == {"foo" => :default}
    end

    it 'works with Array' do
      json = [ OptionsTest.new ].as_json
      json.should == [:default]
    end
  end

  describe 'with Struct' do
    it 'encodes' do
      Struct.new('UserNameAndEmail', :name, :email)
      Struct.new('UserNameAndDate', :name, :date)
      Struct.new('Custom', :name, :sub)
      user_email = Struct::UserNameAndEmail.new 'David', 'sample@example.com'
      user_birthday = Struct::UserNameAndDate.new 'David', Date.new(2010, 01, 01)
      custom = Struct::Custom.new 'David', user_birthday

      json_strings = user_email.to_json
      json_string_and_date = user_birthday.to_json
      json_custom = custom.to_json

      ActiveSupport::JSON.decode(json_custom)
        .should == {
        "name" => "David",
        "sub" => {
          "name" => "David",
          "date" => "2010-01-01" }}

      ActiveSupport::JSON.decode(json_strings)
        .should == {"name" => "David", "email" => "sample@example.com"}

      ActiveSupport::JSON.decode(json_string_and_date)
        .should == {"name" => "David", "date" => "2010-01-01"}
    end
  end

  describe 'with nil, true and false' do
    it 'works' do
      nil.as_json.should == nil
      true.as_json.should == true
      false.as_json.should == false
    end
  end

  describe 'with TimeWithZone' do
    it 'works with use_standard_json_time_format set false' do
      with_standard_json_time_format(false) do
        zone = ActiveSupport::TimeZone['Eastern Time (US & Canada)']
        time = ActiveSupport::TimeWithZone.new(Time.utc(2000), zone)
        ActiveSupport::JSON.encode(time).should == "\"1999/12/31 19:00:00 -0500\""
      end
    end

    it 'works with use_standard_json_time_format set true' do
      with_standard_json_time_format(true) do
        zone = ActiveSupport::TimeZone['Eastern Time (US & Canada)']
        time = ActiveSupport::TimeWithZone.new(Time.utc(2000), zone)
        ActiveSupport::JSON.encode(time).should == "\"1999-12-31T19:00:00.000-05:00\""
      end
    end

    it 'works with custom time precision' do
      with_standard_json_time_format(true) do
        with_time_precision(0) do
          zone = ActiveSupport::TimeZone['Eastern Time (US & Canada)']
          time = ActiveSupport::TimeWithZone.new(Time.utc(2000), zone)
          ActiveSupport::JSON.encode(time).should == "\"1999-12-31T19:00:00-05:00\""
        end
      end
    end
  end

  describe 'with Time' do
    it 'works with custom time precision' do
      with_standard_json_time_format(true) do
        with_time_precision(0) do
          ActiveSupport::JSON.encode(Time.utc(2000)).should == "\"2000-01-01T00:00:00Z\""
        end
      end
    end
  end
end

require 'bigdecimal'

module JSONTest
  class Foo
    def initialize(a, b)
      @a, @b = a, b
    end
  end

  class Hashlike
    def to_hash
      { :foo => "hello", :bar => "world" }
    end
  end

  class Custom
    def initialize(serialized)
      @serialized = serialized
    end

    def as_json(options = nil)
      @serialized
    end
  end

  class MyStruct < Struct.new(:name, :value)
    def initialize(*)
      @unused = "unused instance variable"
      super
    end
  end

  EncodingTestCases = {
    'True'     => [[ true,  %(true)  ]],
    'False'    => [[ false, %(false) ]],
    'Nil'      => [[ nil,   %(null)  ]],
    'Numeric'  => [[ 1,     %(1)     ],
                   [ 2.5,   %(2.5)   ],
                   [ 0.0/0.0,   %(null) ],
                   [ 1.0/0.0,   %(null) ],
                   [ -1.0/0.0,  %(null) ],
                   [ BigDecimal('0.0')/BigDecimal('0.0'),  %(null) ],
                   [ BigDecimal('2.5'), %("#{BigDecimal('2.5')}") ]],

    'String'   => [[ 'this is the <string>',     %("this is the \\u003cstring\\u003e")],
                   [ 'a "string" with quotes & an ampersand', %("a \\"string\\" with quotes \\u0026 an ampersand") ],
                   [ 'http://test.host/posts/1', %("http://test.host/posts/1")],
                   [ "Control characters: \x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10\x11\x12\x13\x14\x15\x16\x17\x18\x19\x1a\x1b\x1c\x1d\x1e\x1f\u2028\u2029",
                     %("Control characters: \\u0000\\u0001\\u0002\\u0003\\u0004\\u0005\\u0006\\u0007\\b\\t\\n\\u000b\\f\\r\\u000e\\u000f\\u0010\\u0011\\u0012\\u0013\\u0014\\u0015\\u0016\\u0017\\u0018\\u0019\\u001a\\u001b\\u001c\\u001d\\u001e\\u001f\\u2028\\u2029") ]],

    'Array'    => [[ ['a', 'b', 'c'],          %([\"a\",\"b\",\"c\"])        ],
                   [ [1, 'a', :b, nil, false], %([1,\"a\",\"b\",null,false]) ]],

    'Hash'     => [[ {foo: "bar"}, %({\"foo\":\"bar\"}) ],
                   [ {1 => 1, 2 => 'a', 3 => :b, 4 => nil, 5 => false}, %({\"1\":1,\"2\":\"a\",\"3\":\"b\",\"4\":null,\"5\":false}) ]],

    'Range'    => [[ 1..2,     %("1..2")],
                   [ 1...2,    %("1...2")],
                   [ 1.5..2.5, %("1.5..2.5")]],

    'Symbol'   => [[ :a,     %("a")    ],
                   [ :this,  %("this") ],
                   [ :"a b", %("a b")  ]],

    'Object'   => [[ Foo.new(1, 2), %({\"a\":1,\"b\":2}) ]],
    'Hashlike' => [[ Hashlike.new, %({\"bar\":\"world\",\"foo\":\"hello\"}) ]],
    'Struct'   => [[ MyStruct.new(:foo, "bar"), %({\"name\":\"foo\",\"value\":\"bar\"}) ],
                   [ MyStruct.new(nil, nil), %({\"name\":null,\"value\":null}) ]],
    'Custom'   => [[ Custom.new("custom"), '"custom"' ],
                   [ Custom.new(nil), 'null' ],
                   [ Custom.new(:a), '"a"' ],
                   [ Custom.new([ :foo, "bar" ]), '["foo","bar"]' ],
                   [ Custom.new({ :foo => "hello", :bar => "world" }), '{"bar":"world","foo":"hello"}' ],
                   [ Custom.new(Hashlike.new), '{"bar":"world","foo":"hello"}' ],
                   [ Custom.new(Custom.new(Custom.new(:a))), '"a"' ]],

    'Regexp'   => [[ /^a/, '"(?-mix:^a)"' ], [/^\w{1,2}[a-z]+/ix, '"(?ix-m:^\\\\w{1,2}[a-z]+)"']],

    'Date'     => [[ Date.new(2005,2,1), %("2005/02/01") ]],
    'Time'     => [[ Time.utc(2005,2,1,15,15,10), %("2005/02/01 15:15:10 +0000") ]],
    # 'DateTime' => [[ DateTime.civil(2005,2,1,15,15,10), %("2005/02/01 15:15:10 +0000") ]]

    'StandardDate'     => [[ Date.new(2005,2,1), %("2005-02-01") ]],
    'StandardTime'     => [[ Time.utc(2005,2,1,15,15,10), %("2005-02-01T15:15:10.000Z") ]],
    # 'StandardDateTime' => [[ DateTime.civil(2005,2,1,15,15,10), %("2005-02-01T15:15:10.000+00:00") ]]
    'StandardString'   => [[ 'this is the <string>', %("this is the <string>")]],
  }
end

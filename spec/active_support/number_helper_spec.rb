describe ActiveSupport::NumberHelper do
  before do
    @all_helpers = [
      Class.new { include ActiveSupport::NumberHelper }.new,
      Module.new { extend ActiveSupport::NumberHelper },
      ActiveSupport::NumberHelper
    ]
  end

  describe '#number_to_phone' do
    it 'should convert' do
      @all_helpers.each do |helper|
        helper.number_to_phone(5551234).should == "555-1234"
        helper.number_to_phone(8005551212).should == "800-555-1212"
        helper.number_to_phone(8005551212, {area_code: true}).should == "(800) 555-1212"
        helper.number_to_phone("", {area_code: true}).should == ""
        helper.number_to_phone(8005551212, {delimiter: " "}).should == "800 555 1212"
        helper.number_to_phone(8005551212, {area_code: true, extension: 123}).should == "(800) 555-1212 x 123"
        helper.number_to_phone(8005551212, extension: "  ").should == "800-555-1212"
        helper.number_to_phone(5551212, delimiter: '.').should == "555.1212"
        helper.number_to_phone("8005551212").should == "800-555-1212"
        helper.number_to_phone(8005551212, country_code: 1).should == "+1-800-555-1212"
        helper.number_to_phone(8005551212, country_code: 1, delimiter: '').should == "+18005551212"
        helper.number_to_phone(225551212).should == "22-555-1212"
        helper.number_to_phone(225551212, country_code: 45).should == "+45-22-555-1212"
      end
    end
  end

  describe '#number_to_currency' do
    it 'should convert' do
      @all_helpers.each do |helper|
        helper.number_to_currency(1234567890.50).should == "$1,234,567,890.50"
        helper.number_to_currency(1234567890.506).should == "$1,234,567,890.51"
        helper.number_to_currency(-1234567890.50).should == "-$1,234,567,890.50"
        helper.number_to_currency(-1234567890.50, {format: "%u %n"}).should == "-$ 1,234,567,890.50"
        helper.number_to_currency(-1234567890.50, {negative_format: "(%u%n)"}).should == "($1,234,567,890.50)"
        helper.number_to_currency(1234567891.50, {precision: 0}).should == "$1,234,567,892"
        helper.number_to_currency(1234567890.50, {precision: 1}).should == "$1,234,567,890.5"
        helper.number_to_currency(1234567890.50, {unit: "&pound;", separator: ",", delimiter: ""}).should == "&pound;1234567890,50"
        helper.number_to_currency("1234567890.50").should == "$1,234,567,890.50"
        helper.number_to_currency("1234567890.50", {unit: "K&#269;", format: "%n %u"}).should == "1,234,567,890.50 K&#269;"
        helper.number_to_currency("-1234567890.50", {unit: "K&#269;", format: "%n %u", negative_format: "%n - %u"}).should == "1,234,567,890.50 - K&#269;"
        helper.number_to_currency(+0.0, {unit: "", negative_format: "(%n)"}).should == "0.00"
        helper.number_to_currency(-0.0, {unit: "", negative_format: "(%n)"}).should == "(0.00)"
      end
    end
  end

  describe '#number_to_percentage' do
    it 'should convert' do
      @all_helpers.each do |helper|
        helper.number_to_percentage(100).should == "100.000%"
        helper.number_to_percentage(100, {precision: 0}).should == "100%"
        helper.number_to_percentage(302.0574, {precision: 2}).should == "302.06%"
        helper.number_to_percentage("100").should == "100.000%"
        helper.number_to_percentage("1000").should == "1000.000%"
        helper.number_to_percentage(123.400, precision: 3, strip_insignificant_zeros: true).should == "123.4%"
        helper.number_to_percentage(1000, delimiter: '.', separator: ',').should == "1.000,000%"
        helper.number_to_percentage(1000, format: "%n  %").should == "1000.000  %"
        helper.number_to_percentage("98a").should == "98a%"
        helper.number_to_percentage(Float::NAN).should == "NaN%"
        helper.number_to_percentage(Float::INFINITY).should == "Inf%"
        helper.number_to_percentage(Float::NAN, precision: 0).should == "NaN%"
        helper.number_to_percentage(Float::INFINITY, precision: 0).should == "Inf%"
        helper.number_to_percentage(Float::NAN, precision: 1).should == "NaN%"
        helper.number_to_percentage(Float::INFINITY, precision: 1).should == "Inf%"
      end
    end
  end

  describe '#number_to_delimited' do
    it 'should convert' do
      @all_helpers.each do |helper|
        helper.number_to_delimited(12345678).should == "12,345,678"
        helper.number_to_delimited(0).should == "0"
        helper.number_to_delimited(123).should == "123"
        helper.number_to_delimited(123456).should == "123,456"
        helper.number_to_delimited(123456.78).should == "123,456.78"
        helper.number_to_delimited(123456.789).should == "123,456.789"
        helper.number_to_delimited(123456.78901).should == "123,456.78901"
        helper.number_to_delimited(123456789.78901).should == "123,456,789.78901"
        helper.number_to_delimited(0.78901).should == "0.78901"
        helper.number_to_delimited("123456.78").should == "123,456.78"
      end
    end

    it 'should convert with options' do
      @all_helpers.each do |helper|
        helper.number_to_delimited(12345678, delimiter: ' ').should == '12 345 678'
        helper.number_to_delimited(12345678.05, separator: '-').should == '12,345,678-05'
        helper.number_to_delimited(12345678.05, separator: ',', delimiter: '.').should == '12.345.678,05'
      end
    end
  end

  describe '#number_to_rounded' do
    it 'should convert' do
      @all_helpers.each do |helper|
        helper.number_to_rounded(-111.2346).should == "-111.235"
        helper.number_to_rounded(111.2346).should == "111.235"
        helper.number_to_rounded(31.825, precision: 2).should == "31.83"
        helper.number_to_rounded(111.2346, precision: 2).should == "111.23"
        helper.number_to_rounded(111, precision: 2).should == "111.00"
        helper.number_to_rounded("111.2346").should == "111.235"
        helper.number_to_rounded("31.825", precision: 2).should == "31.83"
        helper.number_to_rounded((32.6751 * 100.00), precision: 0).should == "3268"
        helper.number_to_rounded(111.50, precision: 0).should == "112"
        helper.number_to_rounded(1234567891.50, precision: 0).should == "1234567892"
        helper.number_to_rounded(0, precision: 0).should == "0"
        helper.number_to_rounded(0.001, precision: 5).should == "0.00100"
        helper.number_to_rounded(0.00111, precision: 3).should == "0.001"
        helper.number_to_rounded(9.995, precision: 2).should == "10.00"
        helper.number_to_rounded(10.995, precision: 2).should == "11.00"
        helper.number_to_rounded(-0.001, precision: 2).should == "0.00"

        # FIXME: BigDecimal and Rational does not work
        # helper.number_to_rounded(111.2346, precision: 20).should == "111.23460000000000000000"
        # helper.number_to_rounded(Rational(1112346, 10000), precision: 20).should == "111.23460000000000000000"
        # helper.number_to_rounded('111.2346', precision: 20).should == "111.23460000000000000000"
        # helper.number_to_rounded(BigDecimal(111.2346, Float::DIG), precision: 20).should == "111.23460000000000000000"
        # helper.number_to_rounded('111.2346', precision: 100).should == "111.2346" + "0"*96
        # helper.number_to_rounded(Rational(1112346, 10000), precision: 4).should == "111.2346"
        # helper.number_to_rounded(Rational(0, 1), precision: 2).should == '0.00'
      end
    end

    it 'should convert with delimiter and separator' do
      @all_helpers.each do |helper|
        helper.number_to_rounded(31.825, precision: 2, separator: ',').should == '31,83'
        helper.number_to_rounded(1231.825, precision: 2, separator: ',', delimiter: '.').should == '1.231,83'
      end
    end

    it 'should convert with significant digits' do
      @all_helpers.each do |helper|
        helper.number_to_rounded(123987, precision: 3, significant: true).should == "124000"
        helper.number_to_rounded(123987876, precision: 2, significant: true ).should == "120000000"
        helper.number_to_rounded("43523", precision: 1, significant: true ).should == "40000"
        helper.number_to_rounded(9775, precision: 4, significant: true ).should == "9775"
        helper.number_to_rounded(5.3923, precision: 2, significant: true ).should == "5.4"
        helper.number_to_rounded(5.3923, precision: 1, significant: true ).should == "5"
        helper.number_to_rounded(1.232, precision: 1, significant: true ).should == "1"
        helper.number_to_rounded(7, precision: 1, significant: true ).should == "7"
        helper.number_to_rounded(1, precision: 1, significant: true ).should == "1"
        helper.number_to_rounded(52.7923, precision: 2, significant: true ).should == "53"
        helper.number_to_rounded(9775, precision: 6, significant: true ).should == "9775.00"
        helper.number_to_rounded(5.3929, precision: 7, significant: true ).should == "5.392900"
        helper.number_to_rounded(0, precision: 2, significant: true ).should == "0.0"
        helper.number_to_rounded(0, precision: 1, significant: true ).should == "0"
        helper.number_to_rounded(0.0001, precision: 1, significant: true ).should == "0.0001"
        helper.number_to_rounded(0.0001, precision: 3, significant: true ).should == "0.000100"
        helper.number_to_rounded(0.0001111, precision: 1, significant: true ).should == "0.0001"
        helper.number_to_rounded(9.995, precision: 3, significant: true).should == "10.0"
        helper.number_to_rounded(9.994, precision: 3, significant: true).should == "9.99"
        helper.number_to_rounded(10.995, precision: 3, significant: true).should == "11.0"

        # FIXME: BigDecimal and Rational does not work
        # helper.number_to_rounded(9775, precision: 20, significant: true ).should == "9775.0000000000000000"
        # helper.number_to_rounded(9775.0, precision: 20, significant: true ).should == "9775.0000000000000000"
        # helper.number_to_rounded(Rational(9775, 1), precision: 20, significant: true ).should == "9775.0000000000000000"
        # helper.number_to_rounded(Rational(9775, 100), precision: 20, significant: true ).should == "97.750000000000000000"
        # helper.number_to_rounded(BigDecimal(9775), precision: 20, significant: true ).should == "9775.0000000000000000"
        # helper.number_to_rounded("9775", precision: 20, significant: true ).should == "9775.0000000000000000"
        # helper.number_to_rounded("9775", precision: 100, significant: true ).should == ("9775." + "0"*96)
        # helper.number_to_rounded(Rational(9772, 100), precision: 3, significant: true).should == "97.7"
      end
    end

    it 'should convert with significant digits and zero precision' do
      @all_helpers.each do |helper|
        helper.number_to_rounded(123.987, precision: 0, significant: true).should == "124"
        helper.number_to_rounded(12, precision: 0, significant: true ).should == "12"
        helper.number_to_rounded("12.3", precision: 0, significant: true ).should == "12"
      end
    end

    it 'should convert with strip insignificant zeros' do
      @all_helpers.each do |helper|
        helper.number_to_rounded(9775.43, precision: 4, strip_insignificant_zeros: true ).should == "9775.43"
        helper.number_to_rounded(9775.2, precision: 6, significant: true, strip_insignificant_zeros: true ).should == "9775.2"
        helper.number_to_rounded(0, precision: 6, significant: true, strip_insignificant_zeros: true ).should == "0"
      end
    end
  end

  describe '#number_to_human_size' do
    use_bytes_methods

    it 'should convert' do
      @all_helpers.each do |helper|
        helper.number_to_human_size(0).should == '0 Bytes'
        helper.number_to_human_size(1).should == '1 Byte'
        helper.number_to_human_size(3.14159265).should == '3 Bytes'
        helper.number_to_human_size(123.0).should == '123 Bytes'
        helper.number_to_human_size(123).should == '123 Bytes'
        helper.number_to_human_size(1234).should == '1.21 KB'
        helper.number_to_human_size(12345).should == '12.1 KB'
        helper.number_to_human_size(1234567).should == '1.18 MB'
        helper.number_to_human_size(1234567890).should == '1.15 GB'
        helper.number_to_human_size(1234567890123).should == '1.12 TB'
        helper.number_to_human_size(terabytes(1026)).should == '1030 TB'
        helper.number_to_human_size(kilobytes(444)).should == '444 KB'
        helper.number_to_human_size(megabytes(1023)).should == '1020 MB'
        helper.number_to_human_size(terabytes(3)).should == '3 TB'
        helper.number_to_human_size(1234567, precision: 2).should == '1.2 MB'
        helper.number_to_human_size(3.14159265, precision: 4).should == '3 Bytes'
        helper.number_to_human_size('123').should == '123 Bytes'
        helper.number_to_human_size(kilobytes(1.0123), precision: 2).should == '1 KB'
        helper.number_to_human_size(kilobytes(1.0100), precision: 4).should == '1.01 KB'
        helper.number_to_human_size(kilobytes(10.000), precision: 4).should == '10 KB'
        helper.number_to_human_size(1.1).should == '1 Byte'
        helper.number_to_human_size(10).should == '10 Bytes'
      end
    end

    it 'should convert with si prefix' do
      @all_helpers.each do |helper|
        helper.number_to_human_size(3.14159265, prefix: :si).should == '3 Bytes'
        helper.number_to_human_size(123.0, prefix: :si).should == '123 Bytes'
        helper.number_to_human_size(123, prefix: :si).should == '123 Bytes'
        helper.number_to_human_size(1234, prefix: :si).should == '1.23 KB'
        helper.number_to_human_size(12345, prefix: :si).should == '12.3 KB'
        helper.number_to_human_size(1234567, prefix: :si).should == '1.23 MB'
        helper.number_to_human_size(1234567890, prefix: :si).should == '1.23 GB'
        helper.number_to_human_size(1234567890123, prefix: :si).should == '1.23 TB'
      end
    end

    it 'should convert with options' do
      @all_helpers.each do |helper|
        helper.number_to_human_size(1234567, precision: 2).should == '1.2 MB'
        helper.number_to_human_size(3.14159265, precision: 4).should == '3 Bytes'
        helper.number_to_human_size(kilobytes(1.0123), precision: 2).should == '1 KB'
        helper.number_to_human_size(kilobytes(1.0100), precision: 4).should == '1.01 KB'
        helper.number_to_human_size(kilobytes(10.000), precision: 4).should == '10 KB'
        helper.number_to_human_size(1234567890123, precision: 1).should == '1 TB'
        helper.number_to_human_size(524288000, :precision=>3).should == '500 MB'
        helper.number_to_human_size(9961472, :precision=>0).should == '10 MB'
        helper.number_to_human_size(41010, precision: 1).should == '40 KB'
        helper.number_to_human_size(41100, precision: 2).should == '40 KB'
        helper.number_to_human_size(kilobytes(1.0123), precision: 2, strip_insignificant_zeros: false).should == '1.0 KB'
        helper.number_to_human_size(kilobytes(1.0123), precision: 3, significant: false).should == '1.012 KB'
        helper.number_to_human_size(kilobytes(1.0123), precision: 0, significant: true) #ignores significant it precision is 0.should == '1 KB'
      end
    end

    it 'should convert with delimiter and separator' do
      @all_helpers.each do |helper|
        helper.number_to_human_size(kilobytes(1.0123), precision: 3, separator: ',').should == '1,01 KB'
        helper.number_to_human_size(kilobytes(1.0100), precision: 4, separator: ',').should == '1,01 KB'
        helper.number_to_human_size(terabytes(1000.1), precision: 5, delimiter: '.', separator: ',').should == '1.000,1 TB'
      end
    end
  end

  describe '#number_to_human' do
    it 'should convert' do
      @all_helpers.each do |helper|
        helper.number_to_human(-123).should == '-123'
        helper.number_to_human(-0.5).should == '-0.5'
        helper.number_to_human(0).should == '0'
        helper.number_to_human(0.5).should == '0.5'
        helper.number_to_human(123).should == '123'
        helper.number_to_human(1234).should == '1.23 Thousand'
        helper.number_to_human(12345).should == '12.3 Thousand'
        helper.number_to_human(1234567).should == '1.23 Million'
        helper.number_to_human(1234567890).should == '1.23 Billion'
        helper.number_to_human(1234567890123).should == '1.23 Trillion'
        helper.number_to_human(1234567890123456).should == '1.23 Quadrillion'
        helper.number_to_human(1234567890123456789).should == '1230 Quadrillion'
        helper.number_to_human(489939, precision: 2).should == '490 Thousand'
        helper.number_to_human(489939, precision: 4).should == '489.9 Thousand'
        helper.number_to_human(489000, precision: 4).should == '489 Thousand'
        helper.number_to_human(489000, precision: 4, strip_insignificant_zeros: false).should == '489.0 Thousand'
        helper.number_to_human(1234567, precision: 4, significant: false).should == '1.2346 Million'
        helper.number_to_human(1234567, precision: 1, significant: false, separator: ',').should == '1,2 Million'
        helper.number_to_human(1234567, precision: 0, significant: true, separator: ',') #significant forced to false.should == '1 Million'
      end
    end

    it 'should convert with units' do
      @all_helpers.each do |helper|
        #Only integers
        volume = {unit: "ml", thousand: "lt", million: "m3"}
        helper.number_to_human(123456, units: volume).should == '123 lt'
        helper.number_to_human(12, units: volume).should == '12 ml'
        helper.number_to_human(1234567, units: volume).should == '1.23 m3'

        #Including fractionals
        distance = {mili: "mm", centi: "cm", deci: "dm", unit: "m", ten: "dam", hundred: "hm", thousand: "km"}
        helper.number_to_human(0.00123, units: distance).should == '1.23 mm'
        helper.number_to_human(0.0123, units: distance).should == '1.23 cm'
        helper.number_to_human(0.123, units: distance).should == '1.23 dm'
        helper.number_to_human(1.23, units: distance).should == '1.23 m'
        helper.number_to_human(12.3, units: distance).should == '1.23 dam'
        helper.number_to_human(123, units: distance).should == '1.23 hm'
        helper.number_to_human(1230, units: distance).should == '1.23 km'
        helper.number_to_human(1230, units: distance).should == '1.23 km'
        helper.number_to_human(1230, units: distance).should == '1.23 km'
        helper.number_to_human(12300, units: distance).should == '12.3 km'

        #The quantifiers don't need to be a continuous sequence
        gangster = {hundred: "hundred bucks", million: "thousand quids"}
        helper.number_to_human(100, units: gangster).should == '1 hundred bucks'
        helper.number_to_human(2500, units: gangster).should == '25 hundred bucks'
        helper.number_to_human(25000000, units: gangster).should == '25 thousand quids'
        helper.number_to_human(12345000000, units: gangster).should == '12300 thousand quids'

        #Spaces are stripped from the resulting string
        helper.number_to_human(4, units: {unit: "", ten: 'tens '}).should == '4'
        helper.number_to_human(45, units: {unit: "", ten: ' tens   '}).should == '4.5  tens'
      end
    end

    it 'should convert with units missing needed key' do
      @all_helpers.each do |helper|
        helper.number_to_human(123, units: {thousand: 'k'}).should == '123'
        helper.number_to_human(123, units: {}).should == '123'
      end
    end

    it 'should convert with format' do
      @all_helpers.each do |helper|
        helper.number_to_human(123456, format: "%n times %u").should == '123 times Thousand'
        volume = {unit: "ml", thousand: "lt", million: "m3"}
        helper.number_to_human(123456, units: volume, format: "%n.%u").should == '123.lt'
      end
    end
  end

  describe 'with nil arg' do
    it 'should return nil' do
      @all_helpers.each do |helper|
        helper.number_to_phone(nil).should == nil
        helper.number_to_currency(nil).should == nil
        helper.number_to_percentage(nil).should == nil
        helper.number_to_delimited(nil).should == nil
        helper.number_to_rounded(nil).should == nil
        helper.number_to_human_size(nil).should == nil
        helper.number_to_human(nil).should == nil
      end
    end
  end

  describe 'of options' do
    it 'should not mutate' do
      @all_helpers.each do |helper|
        options = { 'raise' => true }

        helper.number_to_phone(1, options)
        options.should == { 'raise' => true }

        helper.number_to_currency(1, options)
        options.should == { 'raise' => true }

        helper.number_to_percentage(1, options)
        options.should == { 'raise' => true }

        helper.number_to_delimited(1, options)
        options.should == { 'raise' => true }

        helper.number_to_rounded(1, options)
        options.should == { 'raise' => true }

        helper.number_to_human_size(1, options)
        options.should == { 'raise' => true }

        helper.number_to_human(1, options)
        options.should == { 'raise' => true }
      end
    end
  end

  describe 'with non-numeric arg' do
    it 'should keep arg unchanged' do
      @all_helpers.each do |helper|
        helper.number_to_phone("x", country_code: 1, extension: 123).should == "+1-x x 123"
        helper.number_to_phone("x").should == "x"
        helper.number_to_currency("x.").should == "$x."
        helper.number_to_currency("x").should == "$x"
        helper.number_to_percentage("x").should == "x%"
        helper.number_to_delimited("x").should == "x"
        helper.number_to_rounded("x.").should == "x."
        helper.number_to_rounded("x").should == "x"
        helper.number_to_human_size('x').should == "x"
        helper.number_to_human('x').should == "x"
      end
    end
  end
end

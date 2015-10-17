describe ActiveSupport::NumberHelper do
  describe 'i18n' do
    extend ActiveSupport::NumberHelper

    use_locales [:ts, :empty, :no_negative_format]

    before do
      I18n.backend.store_translations(
        :ts,
        number: {
          format: {
            precision: 3,
            delimiter: ',',
            separator: '.',
            significant: false,
            strip_insignificant_zeros: false
          },
          currency: {
            format: {
              unit: '&$',
              format: '%u - %n',
              negative_format: '(%u - %n)',
              precision: 2
            }
          },
          human: {
            format: {
              precision: 2,
              significant: true,
              strip_insignificant_zeros: true
            },
            storage_units: {
              format: "%n %u",
              units: {
                byte: "b",
                kb: "k"
              }
            },
            decimal_units: {
              format: "%n %u",
              units: {
                deci: {one: "Tenth", other: "Tenths"},
                unit:  "u",
                ten: {one: "Ten", other: "Tens"},
                thousand: "t",
                million: "m",
                billion:"b",
                trillion:"t" ,
                quadrillion:"q"
              }
            }
          },
          percentage: {
            format: { delimiter: '', precision: 2, strip_insignificant_zeros: true }
          },
          precision: {
            format: { delimiter: '', significant: true }
          }
        },
        custom_units_for_number_to_human: {
          mili: "mm",
          centi: "cm",
          deci: "dm",
          unit: "m",
          ten: "dam",
          hundred: "hm",
          thousand: "km"
        }
      )
      I18n.backend.store_translations(:empty, {})
    end

    after do
      I18n.backend.reload!
    end

    describe '#number_to_currency' do
      it 'should convert' do
        number_to_currency(10, locale: :ts).should == "&$ - 10.00"
        number_to_currency(-10, locale: :ts).should == "(&$ - 10.00)"
        number_to_currency(-10, locale: :ts, format: "%n - %u").should == "-10.00 - &$"
      end

      it 'should convert with empty i18n store' do
        number_to_currency(10, locale: :empty).should == "$10.00"
        number_to_currency(-10, locale: :empty).should == "-$10.00"
      end

      it 'should convert with local default format' do
        I18n.backend.store_translations(
          :ts, { number: { format: { separator: ";" } } }
        )
        number_to_currency(10, locale: :ts).should == "&$ - 10;00"
      end

      it 'should convert without currency negative format' do
        I18n.backend.store_translations(
          :no_negative_format,
          number: {
            currency: { format: { unit: '@', format: '%n %u' } }
          }
        )
        number_to_currency(-10, locale: :no_negative_format).should == "-10.00 @"
      end
    end

    describe '#number_to_rounded' do
      it 'should round with i18n precision' do
        #Delimiter was set to ""
        number_to_rounded(10000, locale: :ts).should == "10000"

        #Precision inherited and significant was set
        number_to_rounded(1.0, locale: :ts).should == "1.00"
      end

      it 'should round with i18n precision and empty i18n store' do
        number_to_rounded(123456789.123456789, locale: :empty).should == "123456789.123"
        number_to_rounded(1.0000, locale: :empty).should == "1.000"
      end
    end

    describe '#number_to_delimited' do
      it 'should delimit with i18n delimiter' do
        #Delimiter "," and separator "."
        number_to_delimited(1000000.234, locale: :ts).should == "1,000,000.234"
      end

      it 'should delimit with i18n delimiter and empty i18n store' do
        number_to_delimited(1000000.234, locale: :empty).should == "1,000,000.234"
      end
    end

    describe '#number_to_percentage' do
      it 'should convert to i18n percentage' do
        # to see if strip_insignificant_zeros is true
        number_to_percentage(1, locale: :ts).should == "1%"
        # precision is 2, significant should be inherited
        number_to_percentage(1.2434, locale: :ts).should == "1.24%"
        # no delimiter
        number_to_percentage(12434, locale: :ts).should == "12434%"
      end

      it 'should convert to i18n percentage with empty i18n store' do
        number_to_percentage(1, locale: :empty).should == "1.000%"
        number_to_percentage(1.2434, locale: :empty).should == "1.243%"
        number_to_percentage(12434, locale: :empty).should == "12434.000%"
      end
    end

    describe '#number_to_human_size' do
      it 'should convert to i18n human size' do
        #b for bytes and k for kbytes
        number_to_human_size(2048, locale: :ts).should == "2 k"
        number_to_human_size(42, locale: :ts).should == "42 b"
      end

      it 'should convert to i18n human size with empty i18n store' do
        number_to_human_size(2048, locale: :empty).should == "2 KB"
        number_to_human_size(42, locale: :empty).should == "42 Bytes"
      end
    end

    describe '#number_to_human' do
      it 'should convert to human with default translation scope' do
        #Using t for thousand
        number_to_human(2000, locale: :ts).should == "2 t"
        #Significant was set to true with precision 2, using b for billion
        number_to_human(1234567890, locale: :ts).should == "1.2 b"
        #Using pluralization (Ten/Tens and Tenth/Tenths)
        number_to_human(0.1, locale: :ts).should == "1 Tenth"
        number_to_human(0.134, locale: :ts).should == "1.3 Tenth"
        number_to_human(0.2, locale: :ts).should == "2 Tenths"
        number_to_human(10, locale: :ts).should == "1 Ten"
        number_to_human(12, locale: :ts).should == "1.2 Ten"
        number_to_human(20, locale: :ts).should == "2 Tens"
      end

      it 'should convert to human with empty i18n store' do
        number_to_human(2000, locale: :empty).should == "2 Thousand"
        number_to_human(1234567890, locale: :empty).should == "1.23 Billion"
      end

      it 'should convert to human with custom translation scope' do
        #Significant was set to true with precision 2, with custom translated units
        number_to_human(0.0432, locale: :ts, units: :custom_units_for_number_to_human)
          .should == "4.3 cm"
      end
    end
  end
end

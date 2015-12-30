describe "Date" do
  describe '._parse' do
    it 'parses "1999-12-31 19:00:00"' do
      parts = Date._parse('1999-12-31 19:00:00')
      parts.should == { year: 1999, mon: 12, mday: 31, hour: 19, min: 0, sec: 0 }
    end

    it 'parses "2050-12-31 19:00:00 -10:00"' do
      parts = Date._parse('2050-12-31 19:00:00 -10:00') # i.e., 2050-01-01 05:00:00 UTC
      parts.should == {
        year: 2050, mon: 12, mday: 31, hour: 19, min: 0, sec: 0,
        zone: '-10:00', offset: -36000
      }
    end

    it 'returns empty hash when string without date information is passed in' do
      Date._parse('foobar').should == {}
      Date._parse('   ').should == {}
    end

    it 'parses abbreviated month name' do
      Date._parse('Feb').should == { mon: 2 }
      Date._parse('Feb 3').should == { mon: 2, mday: 3 }
      Date._parse('3 Feb').should == { mon: 2, mday: 3 }
      Date._parse('Feb 005').should == { year: 2005, mon: 2 }
      Date._parse('005 Feb').should == { year: 2005, mon: 2 }
      Date._parse('3 Feb 5').should == { year: 2005, mon: 2, mday: 3 }
      Date._parse('005 Feb 3').should == { year: 2005, mon: 2, mday: 3 }
      Date._parse('Feb 3 5').should == { year: 2005, mon: 2, mday: 3 }
      Date._parse('Feb 005 3').should == { year: 2005, mon: 2, mday: 3 }
    end

    it 'parses javascript date' do
      Date._parse("Mon May 28 2012 00:00:00 GMT-0700 (PDT)").should == {
        year: 2012, mon: 5, mday: 28, hour: 0, min: 0, sec: 0,
        zone: '-0700', offset: -25200
      }
    end

    it 'parses hyphenated date' do
      Date._parse('2015-12-25').should == { year: 2015, mon: 12, mday: 25 }
    end

    it 'parses slashed date' do
      Date._parse('2015/12/25').should == { year: 2015, mon: 12, mday: 25 }
    end

    it 'parses dotted date' do
      Date._parse('2015.12.25').should == { year: 2015, mon: 12, mday: 25 }
    end

    it 'parses date without separator' do
      Date._parse('20151225').should == { year: 2015, mon: 12, mday: 25 }
    end

    it 'parses sec_fraction' do
      Date._parse('17:42:31.987').should == {
        hour: 17, min: 42, sec: 31, sec_fraction: Rational(987, 1000) }
    end
  end
end

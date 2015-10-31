describe "TimeZone" do
  describe '#utc_to_local' do
    it 'works' do
      zone = ActiveSupport::TimeZone['Eastern Time (US & Canada)']
      zone.utc_to_local(Time.utc(2000, 1)).should == Time.utc(1999, 12, 31, 19) # standard offset -0500
      zone.utc_to_local(Time.utc(2000, 7)).should == Time.utc(2000, 6, 30, 20) # dst offset -0400
    end
  end

  describe '#local_to_utc' do
    it 'works' do
      zone = ActiveSupport::TimeZone['Eastern Time (US & Canada)']
      zone.local_to_utc(Time.utc(2000, 1)).should == Time.utc(2000, 1, 1, 5) # standard offset -0500
      zone.local_to_utc(Time.utc(2000, 7)).should == Time.utc(2000, 7, 1, 4) # dst offset -0400
    end
  end

  describe '#period_for_local' do
    it 'returns TZInfo::TimezonePeriod' do
      zone = ActiveSupport::TimeZone['Eastern Time (US & Canada)']
      zone.period_for_local(Time.utc(2000)).is_a?(TZInfo::TimezonePeriod).should.be.true
    end
  end

  describe '.[]' do
    ActiveSupport::TimeZone::MAPPING.each_key do |name|
      it "maps #{name} to tzinfo" do
        zone = ActiveSupport::TimeZone[name]
        zone.tzinfo.respond_to?(:period_for_local).should.be.true
      end
    end

    it 'maps integer' do
      ActiveSupport::TimeZone[-28800].is_a?(ActiveSupport::TimeZone).should.be.true # PST
    end

    it 'maps duration' do
      ActiveSupport::TimeZone[-480.minutes].is_a?(ActiveSupport::TimeZone).should.be.true # PST
    end

    ActiveSupport::TimeZone.all.each do |zone|
      it "maps #{zone.name}" do
        ActiveSupport::TimeZone[zone.name].is_a?(ActiveSupport::TimeZone).should.be.true
      end

      it "responds to utc offset for #{zone.name}" do
        period = zone.tzinfo.current_period
        zone.utc_offset.should == period.utc_offset
      end
    end

    it 'delegates unknown timezones to tzinfo' do
      zone = ActiveSupport::TimeZone['America/Montevideo']
      zone.class.should == ActiveSupport::TimeZone
      ActiveSupport::TimeZone['America/Montevideo'].object_id.should == zone.object_id
      zone.utc_to_local(Time.utc(2010, 2)).should == Time.utc(2010, 1, 31, 22) # daylight saving offset -0200
      zone.utc_to_local(Time.utc(2010, 4)).should == Time.utc(2010, 3, 31, 21) # standard offset -0300
    end

    it 'indexes' do
      ActiveSupport::TimeZone["bogus"].should == nil
      ActiveSupport::TimeZone["Central Time (US & Canada)"].is_a?(ActiveSupport::TimeZone).should == true
      ActiveSupport::TimeZone[8].is_a?(ActiveSupport::TimeZone).should == true
      lambda { ActiveSupport::TimeZone[false] }.should.raise(ArgumentError)
    end
  end

  describe '#now' do
    it 'works' do
      with_env_tz 'US/Eastern' do
        zone = ActiveSupport::TimeZone['Eastern Time (US & Canada)'].dup
        def zone.time_now; Time.local(2000); end
        zone.now.is_a?(ActiveSupport::TimeWithZone).should.be.true
        zone.now.utc.should == Time.utc(2000,1,1,5)
        zone.now.time.should == Time.utc(2000)
        zone.now.time_zone.should == zone
      end
    end

    it 'enforces spring dst rules' do
      with_env_tz 'US/Eastern' do
        zone = ActiveSupport::TimeZone['Eastern Time (US & Canada)'].dup
        def zone.time_now
          Time.local(2006,4,2,2) # 2AM springs forward to 3AM
        end

        zone.now.time.should == Time.utc(2006,4,2,3)
        zone.now.dst?.should == true
      end
    end

    it 'enforces fall dst rules' do
      with_env_tz 'US/Eastern' do
        zone = ActiveSupport::TimeZone['Eastern Time (US & Canada)'].dup
        def zone.time_now
          Time.at(1162098000) # equivalent to 1AM DST
        end
        zone.now.time.should == Time.utc(2006,10,29,1)
        zone.now.dst?.should == true
      end
    end
  end

  describe '#today' do
    it 'works' do
      travel_to(Time.utc(2000, 1, 1, 4, 59, 59)) # 1 sec before midnight Jan 1 EST
      ActiveSupport::TimeZone['Eastern Time (US & Canada)'].today.should == Date.new(1999, 12, 31)
      travel_to(Time.utc(2000, 1, 1, 5)) # midnight Jan 1 EST
      ActiveSupport::TimeZone['Eastern Time (US & Canada)'].today.should == Date.new(2000, 1, 1)
      travel_to(Time.utc(2000, 1, 2, 4, 59, 59)) # 1 sec before midnight Jan 2 EST
      ActiveSupport::TimeZone['Eastern Time (US & Canada)'].today.should == Date.new(2000, 1, 1)
      travel_to(Time.utc(2000, 1, 2, 5)) # midnight Jan 2 EST
      ActiveSupport::TimeZone['Eastern Time (US & Canada)'].today.should == Date.new(2000, 1, 2)
      travel_back
    end
  end

  describe '#tomorrow' do
    it 'works' do
      travel_to(Time.utc(2000, 1, 1, 4, 59, 59)) # 1 sec before midnight Jan 1 EST
      ActiveSupport::TimeZone['Eastern Time (US & Canada)'].tomorrow.should == Date.new(2000, 1, 1)
      travel_to(Time.utc(2000, 1, 1, 5)) # midnight Jan 1 EST
      ActiveSupport::TimeZone['Eastern Time (US & Canada)'].tomorrow.should == Date.new(2000, 1, 2)
      travel_to(Time.utc(2000, 1, 2, 4, 59, 59)) # 1 sec before midnight Jan 2 EST
      ActiveSupport::TimeZone['Eastern Time (US & Canada)'].tomorrow.should == Date.new(2000, 1, 2)
      travel_to(Time.utc(2000, 1, 2, 5)) # midnight Jan 2 EST
      ActiveSupport::TimeZone['Eastern Time (US & Canada)'].tomorrow.should == Date.new(2000, 1, 3)
      travel_back
    end
  end

  describe '#yesterday' do
    it 'works' do
      travel_to(Time.utc(2000, 1, 1, 4, 59, 59)) # 1 sec before midnight Jan 1 EST
      ActiveSupport::TimeZone['Eastern Time (US & Canada)'].yesterday.should == Date.new(1999, 12, 30)
      travel_to(Time.utc(2000, 1, 1, 5)) # midnight Jan 1 EST
      ActiveSupport::TimeZone['Eastern Time (US & Canada)'].yesterday.should == Date.new(1999, 12, 31)
      travel_to(Time.utc(2000, 1, 2, 4, 59, 59)) # 1 sec before midnight Jan 2 EST
      ActiveSupport::TimeZone['Eastern Time (US & Canada)'].yesterday.should == Date.new(1999, 12, 31)
      travel_to(Time.utc(2000, 1, 2, 5)) # midnight Jan 2 EST
      ActiveSupport::TimeZone['Eastern Time (US & Canada)'].yesterday.should == Date.new(2000, 1, 1)
      travel_back
    end
  end

  describe '#local' do
    it 'works' do
      time = ActiveSupport::TimeZone["Hawaii"].local(2007, 2, 5, 15, 30, 45)
      time.time.should == Time.utc(2007, 2, 5, 15, 30, 45)
      time.time_zone.should == ActiveSupport::TimeZone["Hawaii"]
    end

    it 'works with old date' do
      time = ActiveSupport::TimeZone["Hawaii"].local(1850, 2, 5, 15, 30, 45)
      time.to_a[0,6].should == [45,30,15,5,2,1850]
      time.time_zone.should == ActiveSupport::TimeZone["Hawaii"]
    end

    it 'enforces spring dst rules' do
      zone = ActiveSupport::TimeZone['Eastern Time (US & Canada)']
      twz = zone.local(2006,4,2,1,59,59) # 1 second before DST start
      twz.time.should == Time.utc(2006,4,2,1,59,59)
      twz.utc.should == Time.utc(2006,4,2,6,59,59)
      twz.dst?.should == false
      twz.zone.should == 'EST'
      twz2 = zone.local(2006,4,2,2) # 2AM does not exist because at 2AM, time springs forward to 3AM
      twz2.time.should == Time.utc(2006,4,2,3) # twz is created for 3AM
      twz2.utc.should == Time.utc(2006,4,2,7)
      twz2.dst?.should == true
      twz2.zone.should == 'EDT'
      twz3 = zone.local(2006,4,2,2,30) # 2:30AM does not exist because at 2AM, time springs forward to 3AM
      twz3.time.should == Time.utc(2006,4,2,3,30) # twz is created for 3:30AM
      twz3.utc.should == Time.utc(2006,4,2,7,30)
      twz3.dst?.should == true
      twz3.zone.should == 'EDT'
    end

    it 'enforces fall dst rules' do
      # 1AM during fall DST transition is ambiguous, it could be either DST or non-DST 1AM
      # Mirroring Time.local behavior, this method selects the DST time
      zone = ActiveSupport::TimeZone['Eastern Time (US & Canada)']
      twz = zone.local(2006,10,29,1)
      twz.time.should == Time.utc(2006,10,29,1)
      twz.utc.should == Time.utc(2006,10,29,5)
      twz.dst?.should == true
      twz.zone.should == 'EDT'
    end
  end

  describe '#at' do
    it 'works' do
      zone = ActiveSupport::TimeZone['Eastern Time (US & Canada)']
      secs = 946684800.0
      twz = zone.at(secs)
      twz.time.should == Time.utc(1999,12,31,19)
      twz.utc.should == Time.utc(2000)
      twz.time_zone.should == zone
      twz.to_f.should == secs
    end

    it 'works with old date' do
      zone = ActiveSupport::TimeZone['Eastern Time (US & Canada)']
      secs = Time.utc(1850).to_f
      twz = zone.at(secs)
      [twz.utc.year, twz.utc.mon, twz.utc.day, twz.utc.hour].should == [1850, 1, 1, 0]
      twz.time_zone.should == zone
      twz.to_f.should == secs
    end
  end

  describe '#parse' do
    it 'works' do
      zone = ActiveSupport::TimeZone['Eastern Time (US & Canada)']
      twz = zone.parse('1999-12-31 19:00:00')
      twz.time.should == Time.utc(1999,12,31,19)
      twz.utc.should == Time.utc(2000)
      twz.time_zone.should == zone
    end

    it 'parses string with timezone' do
      (-11..13).each do |timezone_offset|
        zone = ActiveSupport::TimeZone[timezone_offset]
        twz = zone.parse('1999-12-31 19:00:00')
        zone.parse(twz.to_s).should == twz
      end
    end

    it 'works with old date' do
      zone = ActiveSupport::TimeZone['Eastern Time (US & Canada)']
      twz = zone.parse('1883-12-31 19:00:00')
      twz.to_a[0,6].should == [0,0,19,31,12,1883]
      twz.time_zone.should == zone
    end

    it 'works with far future date with time zone offset in string' do
      zone = ActiveSupport::TimeZone['Eastern Time (US & Canada)']
      twz = zone.parse('2050-12-31 19:00:00 -10:00') # i.e., 2050-01-01 05:00:00 UTC
      twz.to_a[0,6].should == [0,0,0,1,1,2051]
      twz.time_zone.should == zone
    end

    it 'returns nil when string without date information is passed in' do
      zone = ActiveSupport::TimeZone['Eastern Time (US & Canada)']
      zone.parse('foobar').should == nil
      zone.parse('   ').should == nil
    end

    it 'works with incomplete date' do
      zone = ActiveSupport::TimeZone['Eastern Time (US & Canada)']
      zone.stub!(:now, return: zone.local(1999,12,31))
      twz = zone.parse('19:00:00')
      twz.time.should == Time.utc(1999,12,31,19)
    end

    it 'works with day omitted' do
      with_env_tz 'US/Eastern' do
        zone = ActiveSupport::TimeZone['Eastern Time (US & Canada)']
        zone.parse('Feb', Time.local(2000, 1, 1)).should == Time.local(2000, 2, 1)
        zone.parse('Feb 2005', Time.local(2000, 1, 1)).should == Time.local(2005, 2, 1)
        zone.parse('2 Feb 2005', Time.local(2000, 1, 1)).should == Time.local(2005, 2, 2)
      end
    end

    it 'does not black out system timezone dst jump' do
      with_env_tz('EET') do
        zone = ActiveSupport::TimeZone['Pacific Time (US & Canada)']
        twz = zone.parse('2012-03-25 03:29:00')
        twz.to_a[0,6].should == [0, 29, 3, 25, 3, 2012]
      end
    end

    it 'does black out app timezone dst jump' do
      with_env_tz('EET') do
        zone = ActiveSupport::TimeZone['Pacific Time (US & Canada)']
        twz = zone.parse('2012-03-11 02:29:00')
        twz.to_a[0,6].should == [0, 29, 3, 11, 3, 2012]
      end
    end

    it 'works with missing time components' do
      zone = ActiveSupport::TimeZone['Eastern Time (US & Canada)']
      zone.stub!(:now, return: zone.local(1999, 12, 31, 12, 59, 59))
      twz = zone.parse('2012-12-01')
      twz.time.should == Time.utc(2012, 12, 1)
    end

    it 'works with javascript date' do
      zone = ActiveSupport::TimeZone['Eastern Time (US & Canada)']
      twz = zone.parse("Mon May 28 2012 00:00:00 GMT-0700 (PDT)")
      twz.utc.should == Time.utc(2012, 5, 28, 7, 0, 0)
    end

    it 'does not use local dst' do
      with_env_tz 'US/Eastern' do
        zone = ActiveSupport::TimeZone['UTC']
        twz = zone.parse('2013-03-10 02:00:00')
        twz.time.should == Time.utc(2013, 3, 10, 2, 0, 0)
      end
    end

    it 'handles dst jump' do
      with_env_tz 'US/Eastern' do
        zone = ActiveSupport::TimeZone['Eastern Time (US & Canada)']
        twz = zone.parse('2013-03-10 02:00:00')
        twz.time.should == Time.utc(2013, 3, 10, 3, 0, 0)
      end
    end
  end

  describe '.create' do
    it 'lazy loads utc_offset from tzinfo when not passed in to initialize' do
      tzinfo = TZInfo::Timezone.get('America/New_York')
      zone = ActiveSupport::TimeZone.create(tzinfo.name, nil, tzinfo)
      zone.instance_variable_get('@utc_offset').should == nil
      zone.utc_offset.should == -18_000
    end
  end

  describe '.new' do
    it 'returns TimeZone' do
      ActiveSupport::TimeZone.new("Central Time (US & Canada)")
        .should == ActiveSupport::TimeZone["Central Time (US & Canada)"]
    end
  end

  describe '.seconds_to_utc_offset' do
    it 'works with colon' do
      ActiveSupport::TimeZone.seconds_to_utc_offset(-21_600).should == "-06:00"
      ActiveSupport::TimeZone.seconds_to_utc_offset(0).should == "+00:00"
      ActiveSupport::TimeZone.seconds_to_utc_offset(18_000).should == "+05:00"
    end

    it 'works without colon' do
      ActiveSupport::TimeZone.seconds_to_utc_offset(-21_600, false).should == "-0600"
      ActiveSupport::TimeZone.seconds_to_utc_offset(0, false).should == "+0000"
      ActiveSupport::TimeZone.seconds_to_utc_offset(18_000, false).should == "+0500"
    end

    it 'works with negative offset' do
      ActiveSupport::TimeZone.seconds_to_utc_offset(-3_600).should == "-01:00"
      ActiveSupport::TimeZone.seconds_to_utc_offset(-3_599).should == "-00:59"
      ActiveSupport::TimeZone.seconds_to_utc_offset(-19_800).should == "-05:30"
    end
  end

  describe '#formatted_offset' do
    it 'works with positive' do
      zone = ActiveSupport::TimeZone['New Delhi']
      zone.formatted_offset.should == "+05:30"
      zone.formatted_offset(false).should == "+0530"
    end

    it 'works with negative' do
      zone = ActiveSupport::TimeZone['Eastern Time (US & Canada)']
      zone.formatted_offset.should == "-05:00"
      zone.formatted_offset(false).should == "-0500"
    end
  end

  describe '#strftime' do
    it 'works with z format strings' do
      zone = ActiveSupport::TimeZone['Tokyo']
      twz = zone.now
      twz.strftime('%z').should == '+0900'
      twz.strftime('%:z').should == '+09:00'
      twz.strftime('%::z').should == '+09:00:00'
    end
  end

  describe '#formatted_offset' do
    it 'works with zero' do
      zone = ActiveSupport::TimeZone['London']
      zone.formatted_offset.should == "+00:00"
      zone.formatted_offset(true, 'UTC').should == "UTC"
    end
  end

  describe 'operators' do
    it 'compares' do
      zone1 = ActiveSupport::TimeZone['Central Time (US & Canada)'] # offset -0600
      zone2 = ActiveSupport::TimeZone['Eastern Time (US & Canada)'] # offset -0500
      (zone1 < zone2).should == true
      (zone2 > zone1).should == true
      (zone1 == zone1).should == true
    end

    it 'matches' do
      zone = ActiveSupport::TimeZone['Eastern Time (US & Canada)']
      (zone =~ /Eastern/).should == true
      (zone =~ /New_York/).should == true
      (zone !~ /Nonexistent_Place/).should == true
    end
  end

  describe '#to_s' do
    it 'works' do
      ActiveSupport::TimeZone['New Delhi'].to_s.should == "(GMT+05:30) New Delhi"
    end
  end

  describe '.all' do
    it 'is sorted' do
      ActiveSupport::TimeZone.all.each_cons(2) do |x, y|
        (x < y).should == true
      end
    end
  end

  describe 'unknown zone' do
    it 'has tzinfo have tzinfo but exception on utc_offset with unknown zone' do
      zone = ActiveSupport::TimeZone.create("bogus")
      zone.tzinfo.is_a?(TZInfo::TimezoneProxy).should == true
      lambda { zone.utc_offset }.should.raise(TZInfo::InvalidTimezoneIdentifier)
    end

    it 'returns utc_offset' do
      zone = ActiveSupport::TimeZone.create("bogus", -21_600)
      zone.utc_offset.should == -21_600
    end

    it 'does not store mapping keys' do
      ActiveSupport::TimeZone["bogus"]
      ActiveSupport::TimeZone.zones_map.key?("bogus").should == false
    end
  end

  describe '.us_zones' do
    it 'works' do
      ActiveSupport::TimeZone.us_zones.include?(ActiveSupport::TimeZone["Hawaii"])
        .should == true
      ActiveSupport::TimeZone.us_zones.include?(ActiveSupport::TimeZone["Kuala Lumpur"])
        .should == false
    end
  end
end

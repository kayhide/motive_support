require __ORIGINAL__

module TZInfo
  class RubyCountryInfo < CountryInfo
    class Zones
      # Called by the index data to define a timezone for the country.
      def timezone(identifier, latitude_numerator, latitude_denominator, 
                   longitude_numerator, longitude_denominator, description = nil)
        @list << CountryTimezone.new(
          identifier,
          [latitude_numerator, latitude_denominator],
          [longitude_numerator, longitude_denominator],
          description
        )
      end
    end
  end
end

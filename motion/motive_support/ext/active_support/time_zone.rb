module ActiveSupport
  class TimeZone
    class << self
      def new *args
        super *args
      end
    end
  end
end

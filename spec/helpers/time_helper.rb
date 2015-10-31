Module.new do
  def travel_to date_or_time, &block
    if date_or_time.is_a?(Date) && !date_or_time.is_a?(DateTime)
      now = date_or_time.midnight.to_time
    else
      now = date_or_time.to_time.change(usec: 0)
    end

    Time.stub!(:now, return: now)
    Date.stub!(:today, return: now.to_date)
    # DateTime.stub!(:now, return: now.to_datetime)

    if block_given?
      begin
        yield
      ensure
        travel_back
      end
    end
  end

  def travel_back
    Time.reset(:now)
    Date.reset(:today)
    # DateTime.reset(:now)
  end

  Bacon::Context.send :include, self
end

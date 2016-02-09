describe 'Logger' do
  before do
    @message = "A debug message"
    @integer_message = 12345
    @output = StringIO.new
    @logger = ActiveSupport::Logger.new(@output)
  end

  describe '#add' do
    it 'logs debugging message when debugging' do
      @logger.level = ActiveSupport::Logger::DEBUG
      @logger.add(ActiveSupport::Logger::DEBUG, @message)
      @output.string.include?(@message).should == true
    end

    it 'does not log debug messages when log level is info' do
      @logger.level = ActiveSupport::Logger::INFO
      @logger.add(ActiveSupport::Logger::DEBUG, @message)
      @output.string.include?(@message).should == false
    end

    it 'adds message passed as block when using add' do
      @logger.level = ActiveSupport::Logger::INFO
      @logger.add(ActiveSupport::Logger::INFO) { @message }
      @output.string.include?(@message).should == true
    end

    it 'does not evaluate block if message wont be logged' do
      @logger.level = ActiveSupport::Logger::INFO
      evaluated = false
      @logger.add(ActiveSupport::Logger::DEBUG) { evaluated = true }
      evaluated.should == false
    end
  end

  describe '#info' do
    it 'adds message passed as block when using shortcut' do
      @logger.level = ActiveSupport::Logger::INFO
      @logger.info { @message }
      @output.string.include?(@message).should == true
    end

    it 'converts message to string' do
      @logger.level = ActiveSupport::Logger::INFO
      @logger.info @integer_message
      @output.string.include?(@integer_message.to_s).should == true
    end

    it 'converts message to string when passed in block' do
      @logger.level = ActiveSupport::Logger::INFO
      @logger.info { @integer_message }
      @output.string.include?(@integer_message.to_s).should == true
    end

    it 'does not mutate message' do
      message_copy = @message.dup
      @logger.info @message
      message_copy.should == @message
    end

    it 'buffers multibyte' do
      @logger.level = ActiveSupport::Logger::INFO
      @logger.info unicode_string
      @logger.info byte_string
      @output.string.include?(unicode_string).should == true
      byte_string = @output.string.dup
      byte_string.force_encoding("ASCII-8BIT")
      byte_string.include?(byte_string).should == true
    end
  end

  describe 'loglebel method' do
    it 'returns if its loglevel is below a given level' do
      levels = [:DEBUG, :INFO, :WARN, :ERROR, :FATAL]
      n = levels.length
      expected = levels.each_with_index.map do |level, i|
        [level, [false] * i + [true] * ( n - i )]
      end.to_h
      levels.each do |level|
        @logger.level = ActiveSupport::Logger::Severity.const_get(level)
        levels.map { |l| @logger.send("#{l.to_s.downcase}?") }.should == expected[level]
      end
    end
  end

  describe '#silence' do
    it 'does not log everything but errors' do
      @logger.silence do
        @logger.debug "NOT THERE"
        @logger.error "THIS IS HERE"
      end

      @output.string.include?("NOT THERE").should == false
      @output.string.include?("THIS IS HERE").should == true
    end
  end
end

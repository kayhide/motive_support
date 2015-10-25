describe "duplicable?" do
  before do
    @raise_dup = [nil, false, true, :symbol, 1, 2.3, BigDecimal.new('4.56')]
    @allow_dup = ['1', Object.new, /foo/, [], {}, Time.now, Class.new, Module.new]
  end
  
  it "should return false for non-duplicable objects" do
    @raise_dup.each do |v|
      v.should.not.be.duplicable
    end
  end
  
  it "should return true for duplicable objects" do
    @allow_dup.each do |v|
      v.should.be.duplicable
    end
  end
  
  it "should not raise when dupping duplicable objects" do
    @allow_dup.each do |v|
      lambda { v.dup }.should.not.raise
    end
  end
  
  it "should raise when dupping non-duplicable objects" do
    @raise_dup.each do |v|
      lambda { v.dup }.should.raise TypeError
    end
  end
end

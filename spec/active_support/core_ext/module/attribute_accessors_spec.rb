describe "module" do
  describe "attribute accessors" do
    before do
      m = @mod = Module.new do
        mattr_accessor :foo
        mattr_accessor :bar, :instance_writer => false
        mattr_reader   :shaq, :instance_reader => false
        mattr_accessor :camp, :instance_accessor => false

        mattr_accessor(:defa) { 'default_accessor_value' }
        mattr_reader(:defr) { 'default_reader_value' }
        mattr_writer(:defw) { 'default_writer_value' }
        mattr_accessor(:quux) { :quux }
      end
      @object = Class.new { include m }.new
    end
    
    describe "reader" do
      it "should return nil by default" do
        @mod.foo.should.be.nil
      end
    end
    
    describe "writer" do
      it "should set value" do
        @mod.foo = :test
        @mod.foo.should == :test
      end
      
      it "should set value through instance writer" do
        @object.foo = :bar
        @object.foo.should == :bar
      end
      
      it "should set instance reader's value through module's writer" do
        @mod.foo = :test
        @object.foo.should == :test
      end
      
      it "should set module reader's value through instances's writer" do
        @object.foo = :bar
        @mod.foo.should == :bar
      end
    end
    
    describe "instance_writer => false" do
      it "should not create instance writer" do
        @mod.should.respond_to :foo
        @mod.should.respond_to :foo=
        @object.should.respond_to :bar
        @object.should.not.respond_to :bar=
      end
    end
    
    describe "instance_reader => false" do
      it "should not create instance reader" do
        @mod.should.respond_to :shaq
        @object.should.not.respond_to :shaq
      end
    end
  
    describe "instance_accessor => false" do
      it "should not create reader or writer" do
        @mod.should.respond_to :camp
        @object.should.not.respond_to :camp
        @object.should.not.respond_to :camp=
      end
    end

    it 'should use default value if block passed' do
      @mod.defa.should == 'default_accessor_value'
      @mod.defr.should == 'default_reader_value'
      @mod.class_variable_get('@@defw').should == 'default_writer_value'
    end
  end
  
  describe "invalid attribute accessors" do
    it "should raise NameError when creating an invalid reader" do
      lambda do
        Class.new do
          mattr_reader "invalid attribute name"
        end
      end.should.raise NameError
    end
    
    it "should raise NameError when creating an invalid writer" do
      lambda do
        Class.new do
          mattr_writer "invalid attribute name"
        end
      end.should.raise NameError
    end
  end
end

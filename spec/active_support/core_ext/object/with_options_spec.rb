describe "OptionMerger" do
  def method_with_options(options = {})
    options
  end

  before do
    @options = { hello: 'world' }
  end

  describe '#with_options' do
    it 'merges options when options are present' do
      local_options = { cool: true }

      with_options(@options) do |o|
        local_options.should == method_with_options(local_options)
        @options.merge(local_options).should == o.method_with_options(local_options)
      end
    end

    it 'appends options when options are missing' do
      with_options(@options) do |o|
        Hash.new.should == method_with_options
        @options.should == o.method_with_options
      end
    end

    it 'allows to overwrite options' do
      local_options = { hello: 'moon' }
      @options.keys.should == local_options.keys

      with_options(@options) do |o|
        local_options.should == method_with_options(local_options)
        o.method_with_options(local_options)
          .should == @options.merge(local_options)
        local_options.should == o.method_with_options(local_options)
      end
      with_options(local_options) do |o|
        local_options.merge(@options).should == o.method_with_options(@options)
      end
    end

    it 'mereges containing hashes whent nested' do
      with_options(conditions: { method: :get }) do |outer|
        outer.with_options(conditions: { domain: "www" }) do |inner|
          expected = { conditions: { method: :get, domain: "www" } }
          expected.should == inner.method_with_options
        end
      end
    end

    it 'overwrites containing hashes when nested' do
      with_options(conditions: { method: :get, domain: "www" }) do |outer|
        outer.with_options(conditions: { method: :post }) do |inner|
          expected = { conditions: { method: :post, domain: "www" } }
          expected.should == inner.method_with_options
        end
      end
    end

    it 'goes deep containing hashes when nested' do
      with_options(html: { class: "foo", style: { margin: 0, display: "block" } }) do |outer|
        outer.with_options(html: { title: "bar", style: { margin: "1em", color: "#fff" } }) do |inner|
          expected = { html: { class: "foo", title: "bar", style: { margin: "1em", display: "block", color: "#fff" } } }
          expected.should == inner.method_with_options
        end
      end
    end

    it 'uses lambda' do
      local_lambda = lambda { { lambda: true } }
      with_options(@options) do |o|
        @options.merge(local_lambda.call).should == o.method_with_options(local_lambda).call
      end
    end
  end

  it 'uses implicit receiver' do
    @options.with_options foo: "bar" do
      merge! fizz: "buzz"
    end

    @options.should == { hello: "world", foo: "bar", fizz: "buzz" }
  end
end

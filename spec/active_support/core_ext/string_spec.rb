describe "string" do
  describe "constantize" do
    extend ConstantizeTestCases

    it "should constantize" do
      run_constantize_tests_on(&:constantize)
    end
  end

  describe "safe_constantize" do
    extend ConstantizeTestCases

    it "should safe_constantize" do
      run_safe_constantize_tests_on(&:safe_constantize)
    end
  end
end

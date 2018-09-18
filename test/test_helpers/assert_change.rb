module TestHelpers
  module AssertChange
    # assert_difference on steroids
    #
    # == Example
    #
    # assert_change :of => lambda { @article.title }, :from => 'foo', :to => 'bar' do
    #   @article.foo_to_bar!
    # end
    #
    def assert_change(options)
      raise ArgumentError, 'The :of options has to be set to a proc that returns a value whose change is begin asserted' unless options[:of] && options[:of].respond_to?(:call)

      old_value = options[:of].call

      if options.has_key?(:from)
        assert_equal options[:from], old_value,
          "value did not originally match #{options[:from].inspect}"
      end

      yield

      new_value = options[:of].call

      if options.has_key?(:to)
        assert_equal options[:to], new_value,
          "value was not changed to match #{options[:to].inspect}"
      end

      if options[:by]
        expected_value = old_value
        expected_value += options[:by] unless options[:by].zero?

        assert_equal expected_value, new_value, "value did not change by #{options[:by].inspect}"
      end
    end

    # Opposite of assert_change
    def assert_no_change(options, &block)
      assert_change(:of => options[:of], :by => 0, &block)
    end
  end
end

ActiveSupport::TestCase.send(:include, TestHelpers::AssertChange)

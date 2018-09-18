module TestHelpers
  module FormSelectAssertions
    KEYS_FOR_ASSERT_SELECT = [:count, :minimum, :maximum] unless defined?(KEYS_FOR_ASSERT_SELECT)

    # Asserts presence of form on page.
    #
    # == Examples
    #
    #   # Just asserts there is any form.
    #   assert_select_form
    #
    #   # Assets that there is form with given action.
    #   assert_select_form '/posts'
    #
    #   # alternatively
    #   assert_select_form :action => '/posts'
    #
    #   # with method
    #   assert_select_form '/posts', :method => :post
    #
    #   # or
    #   assert_select_form :action => '/posts', :method => :post
    #
    #   # Handles also methods not supported by browsers
    #   assert_select_form '/posts/hello-world', :method => :delete
    #
    # The last example will actually checks for presence of hidden input field
    # with name "_method" and value "delete".
    #
    def assert_select_form(*args, &block)
      options = args.extract_options!
      options[:action] = args.first if args.first

      method = options.delete(:method)
      method &&= method.to_s.downcase

      options_for_assert_select = options.slice(*KEYS_FOR_ASSERT_SELECT)
      options.except!(*KEYS_FOR_ASSERT_SELECT)

      selector, params = options.inject(['form', []]) do |memo, (name, value)|
        memo[0] << "[#{name}=?]"
        memo[1] << value

        memo
      end

      # If method is specified, and it's POST or GET, check that "method" attribute
      # is set to the expected method and check that there is NO fake _method field.
      #
      # If method is something else than POST or GET, check that "method" attribute
      # is set to POST and that there is hidden input field with name "_method" and
      # value set to the expected method (the fake method).
      if method
        if ['get', 'post'].include?(method)
          selector << "[method=#{method}]"
          content_assert_params = ['input[name=_method]', false]
        else
          selector << '[method=post]'
          content_assert_params = ["input[type=hidden][name=_method][value=#{method}]"]
        end
      end

      params << options_for_assert_select

      if block_given? || content_assert_params
        assert_select selector, *params do
          assert_select *content_assert_params if content_assert_params
          yield if block_given?
        end
      else
        assert_select selector, *params
      end
    end

    # Opposite of assert_select_form. Asserts that there is no form.
    def assert_select_no_form(*args, &block)
      options = args.extract_options!
      options[:count] = 0
      args << options

      assert_select_form(*args, &block)
    end

    # This cam be used to test for buttons generated with +button_to+ helper.
    #
    # == Example
    #
    #   assert_select_button_to '/posts/hello-world', :method => :delete
    #
    def assert_select_button_to(*args)
      assert_select_form(*args) { assert_select 'input[type=submit]' }
    end

    def assert_select_no_button_to(*args)
      options = args.extract_options!
      options[:count] = 0
      args << options

      assert_select_button_to(*args)
    end
  end
end

ActiveSupport::TestCase.send(:include, TestHelpers::FormSelectAssertions)

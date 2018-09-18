module ShouldaMacros
  module Common
    module ShouldMethods
      def should_require_login
        should_redirect_to 'login_url'
      end

      # Test that menu with given id is currently active
      #
      # == Example
      #
      #   should_activate_menu :dashboard
      def should_activate_menu(menu)
        should "activate #{menu} menu" do
          assert_active_menu(menu)
        end
      end

      # Text that the given bloc when called raises given exception.
      def should_raise(exception_class, message = nil, &block)
        should ['raise', exception_class.to_s, message].compact.join(' ') do
          raised = false

          begin
            block.bind(self).call
          rescue exception_class
            raised = true
          rescue Exception
            raise
          end

          flunk "<#{exception_class}> exception expected, none was raised" unless raised
          # assert_raise exception_class, &block.bind(self)
        end
      end
    end
  end
end

ActiveSupport::TestCase.extend(ShouldaMacros::Common::ShouldMethods)

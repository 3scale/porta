module DeveloperPortal::ActionController
  class TestCase < ::ActionController::TestCase
    setup { @routes = DeveloperPortal::Engine.routes }
  end
end

module DeveloperPortal::ActionView
  class TestCase < ::ActionView::TestCase
    class TestController < ::ActionView::TestCase::TestController
      def self._routes
        DeveloperPortal::Engine.routes
      end
    end

    def setup_with_controller
      super
      @controller = DeveloperPortal::ActionView::TestCase::TestController.new
    end
  end
end

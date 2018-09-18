module TestHelpers
  module Menu
    def assert_active_menu(menu)
      assert_equal menu, assigns(:active_menus).try!(:[], :main_menu)
    end
  end
end

ActionController::TestCase.class_eval do
  include TestHelpers::Menu
end

ActionDispatch::IntegrationTest.class_eval do
  include TestHelpers::Menu
end

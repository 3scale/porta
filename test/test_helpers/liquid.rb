module TestHelpers
  module Liquid
    module ModelHelpers
      extend self

      def stub_liquid_page_for(account, title)
        page = Factory.stub(:liquid_page, :title => title)
        account.stubs(:liquid_page_for).with(title).returns(page)
        page
      end

      def stub_all_liquid_pages_for(account)
        Dir["#{Rails.root}/lib/themes/default/*.liquid"].each do |title|
          stub_liquid_page_for(account, File.basename(title, '.liquid'))
        end
      end
    end

    module ControllerHelpers
      def expect_render_with_liquid_page(page)
        @controller.expects(:liquidize).with(page.content, any_parameters)
      end
    end
  end
end

ActiveSupport::TestCase.send(:include, TestHelpers::Liquid::ModelHelpers)
ActionController::TestCase.send(:include, TestHelpers::Liquid::ControllerHelpers)

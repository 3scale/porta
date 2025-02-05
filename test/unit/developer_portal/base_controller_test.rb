require 'test_helper'

module DeveloperPortal
  class BaseControllerTest < ActiveSupport::TestCase

    class TestController < DeveloperPortal::BaseController; end

    class FilterReadOnlyParamsTest < BaseControllerTest

      test 'filters out read-only fields' do
        account = FactoryBot.create(:simple_provider)
        ro_fields = FactoryBot.create_list(:fields_definition, 2, account:, read_only: true)
        FactoryBot.create_list(:fields_definition, 3, account:)
        params = account.fields_definitions.each_with_object({}) { |fd, p| p[fd.name]=SecureRandom.hex }
        TestController.any_instance.expects(:site_account).returns(account)

        result = TestController.new.send(:filter_readonly_params, params, User)

        assert_equal 3, result.size
        assert_not_includes result, ro_fields.map(&:name)
      end

    end
  end
end

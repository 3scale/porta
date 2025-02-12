# frozen_string_literal: true

require 'test_helper'

module DeveloperPortal
  class BaseControllerTest < ActionDispatch::IntegrationTest

    class FilterReadOnlyParamsTest < BaseControllerTest
      class TestController < DeveloperPortal::BaseController
        skip_before_action :login_required

        def create
          render plain: filter_readonly_params(params[:user], User)
        end
      end

      test 'filters out read-only fields' do
        account = FactoryBot.create(:simple_provider)
        ro_fields = FactoryBot.create_list(:fields_definition, 2, account:, read_only: true)
        editable_fields = FactoryBot.create_list(:fields_definition, 3, account:)

        ro_params = fields_to_hash(ro_fields)
        editable_params = fields_to_hash(editable_fields)

        TestController.any_instance.expects(:site_account).at_least_once.returns(account)

        with_test_routes do
          post '/test/create', params: { user: {**ro_params, **editable_params} }

          assert_response :success
          assert_equal editable_params.to_s, response.body
        end
      end
    end

    private

    def fields_to_hash(fields)
      fields.each_with_object({}) { |fd, p| p[fd.name]=SecureRandom.hex }
    end

    def with_test_routes
      Rails.application.routes.draw do
        post '/test/create' => 'developer_portal/base_controller_test/filter_read_only_params_test/test#create'
      end
      yield
    ensure
      Rails.application.routes_reloader.reload!
    end
  end
end

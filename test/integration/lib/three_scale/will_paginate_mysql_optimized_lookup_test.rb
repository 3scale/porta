# frozen_string_literal: true

require 'test_helper'

# The warning of ThreeScale::WillPaginateMysqlOptimizedLookup names the controller and action that paginated, taken
# from ActiveSupport::ExecutionContext.  This checks that Rails really sets it during a request.
class ThreeScale::WillPaginateMysqlOptimizedLookupIntegrationTest < ActionDispatch::IntegrationTest
  class PaginatingController < ApplicationController
    skip_before_action :verify_authenticity_token, raise: false

    def index
      # DISTINCT is not supported by the optimized lookup, so it logs a warning.  The lookup hooks into `to_a`
      # only, `map`, `each` and `load` on the relation bypass it.
      render json: User.distinct.paginate(page: 2, per_page: 1).to_a.map(&:id)
    end
  end

  test 'the warning names the controller and action of a real request' do
    skip 'requires MySQL' unless System::Database.mysql?

    messages = nil
    with_test_routes do
      messages = capture_log_messages { get '/test/paginating' }
    end

    assert_response :success
    warnings = messages.grep(/\[WillPaginateMysqlOptimizedLookup\]/)
    assert_equal 1, warnings.size, messages.join("\n")
    assert_match(/User page 2 is not optimized \(DISTINCT\), called from #{Regexp.escape(PaginatingController.name)}#index/,
                 warnings.first)
  end

  private

  def with_test_routes
    Rails.application.routes.draw do
      get '/test/paginating' => 'three_scale/will_paginate_mysql_optimized_lookup_integration_test/paginating#index'
    end
    yield
  ensure
    Rails.application.routes_reloader.reload!
  end
end

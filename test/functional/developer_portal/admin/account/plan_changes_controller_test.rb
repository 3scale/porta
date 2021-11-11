# frozen_string_literal: true

require 'test_helper'

class DeveloperPortal::Admin::Account::PlanChangesControllerTest < DeveloperPortal::AbstractPaymentGatewaysControllerTest

  self.payment_gateway_type = :bogus

  test '#new' do
    get :new, params: { plan_id: @paid_plan.id, contract_id: @application.id }

    assert_redirected_to(@controller.instance_eval { payment_details_path })

    assert_equal({ @application.id.to_s => @paid_plan.id }, session['plan_changes'])
  end

  test '#destroy with changes in session' do
    @controller.send(:store_plan_change!, @application.id, @paid_plan.id)

    delete :destroy, params: { id: @application.id }
    assert_redirected_to admin_application_path(@application)
    assert_equal({}, @controller.session[:plan_changes])
  end

  test '#index' do
    @controller.send(:store_plan_change!, @application.id, @paid_plan.id)

    get :index

    assert_equal 1, @controller.assigns_for_liquify['plan_changes'].count
    assert_response :success
  end
end

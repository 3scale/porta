require 'test_helper'

class DeveloperPortal::Admin::ContractsControllerTest < DeveloperPortal::AbstractPaymentGatewaysControllerTest
  self.payment_gateway_type = :bogus

  def test_update
    Contract.any_instance.expects(:buyer_changes_plan!).with(@paid_plan)
    put :update, id: @application.id, plan_id: @paid_plan.id
    assert_redirected_to admin_application_path(@application.id)
  end

  def test_update_with_referer
    Contract.any_instance.expects(:buyer_changes_plan!).with(@paid_plan)
    request.env['HTTP_REFERER'] = 'http://3scale.net'
    put :update, id: @application.id, plan_id: @paid_plan.id
    assert_redirected_to 'http://3scale.net'
  end

  def test_update_with_plan_changes
    session[:plan_changes] = { @application.id.to_s => @paid_plan.id }
    Contract.any_instance.expects(:buyer_changes_plan!).with(@paid_plan)
    put :update, id: @application.id, plan_id: @paid_plan.id
    assert_equal({}, session[:plan_changes])
    assert_redirected_to admin_application_path(@application.id)
  end

  def test_update_with_plan_changes_with_referer
    request.env['HTTP_REFERER'] = 'http://3scale.net'
    session[:plan_changes] = { @application.id.to_s => @paid_plan.id }
    Contract.any_instance.expects(:buyer_changes_plan!).with(@paid_plan)
    put :update, id: @application.id, plan_id: @paid_plan.id
    assert_equal({}, session[:plan_changes])
    assert_redirected_to admin_application_path(@application.id)
  end
end

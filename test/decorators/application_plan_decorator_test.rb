# frozen_string_literal: true

require 'test_helper'

class ApplicationPlanDecoratorTest < Draper::TestCase
  def test_path
    service = Service.new
    service.id = 1

    plan = ApplicationPlan.new(service: service)
    plan.id = 42

    decorator = ApplicationPlanDecorator.new(plan)
    assert_equal "#{System::UrlHelpers.system_url_helpers.admin_service_applications_path(service)}?search%5Bplan_id%5D=42", decorator.plan_path

    decorator = ApplicationPlanDecorator.new(plan, context: { service: other = Service.new })
    other.id = 2

    assert_equal "#{System::UrlHelpers.system_url_helpers.admin_service_applications_path(other)}?search%5Bplan_id%5D=42", decorator.plan_path
  end

  def test_link_to_edit
    plan = Plan.new
    plan.id = 42
    plan.name = 'foobar'

    decorator = ApplicationPlanDecorator.new(plan)

    assert_equal '<a href="/apiconfig/application_plans/42/edit">foobar</a>',
                 decorator.link_to_edit
  end

  def test_link_to_applications
    service = Service.new
    service.id = 4
    plan = ApplicationPlan.new(service: service)

    decorator = ApplicationPlanDecorator.new(plan)

    assert_equal '0 applications', decorator.link_to_applications

    helpers.expects(:can?).with(:show, Cinstance).returns(true)
    assert_equal "<a href=\"#{System::UrlHelpers.system_url_helpers.admin_service_applications_path(service)}?search%5Bplan_id%5D=\">0 applications</a>",
                 decorator.link_to_applications
  end

  test '#index_table_data' do
    plan = FactoryBot.create(:application_plan, service: FactoryBot.create(:service))
    data = plan.decorate.index_table_data

    assert data.assert_valid_keys(:id, :name, :editPath, :contracts, :contractsPath, :state, :actions)
  end
end

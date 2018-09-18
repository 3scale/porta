require 'test_helper'

class PlanDecoratorTest < Draper::TestCase

  def test_path
    service = Service.new
    service.id = 1

    plan = ApplicationPlan.new(service: service)
    plan.id = 42

    decorator = PlanDecorator.new(plan)
    assert_equal '/admin/apiconfig/services/1/applications?search%5Bplan_id%5D=42', decorator.plan_path

    decorator = PlanDecorator.new(plan, context: { service: other = Service.new })
    other.id = 2

    assert_equal '/admin/apiconfig/services/2/applications?search%5Bplan_id%5D=42', decorator.plan_path
  end

  def test_link_to_edit
    plan = Plan.new
    plan.id = 42
    plan.name = 'foobar'

    decorator = PlanDecorator.new(plan)

    assert_equal '<a href="/apiconfig/application_plans/42/edit">foobar</a>',
                 decorator.link_to_edit
  end

  def test_link_to_applications
    service = Service.new
    service.id = 4
    plan = ApplicationPlan.new(service: service)

    decorator = PlanDecorator.new(plan)

    assert_equal '0 applications', decorator.link_to_applications

    helpers.expects(:can?).with(:show, Cinstance).returns(true)
    assert_equal '<a href="/admin/apiconfig/services/4/applications?search%5Bplan_id%5D=">0 applications</a>',
                 decorator.link_to_applications
  end
end

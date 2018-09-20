require 'test_helper'

class ServiceDecoratorTest < Draper::TestCase

  def test_link_to_live_applications
    service = Service.new
    service.id = 2

    decorator = ServiceDecorator.new(service)

    assert_equal '0 live applications', decorator.link_to_live_applications

    helpers.expects(:can?).with(:show, Cinstance).returns(true)
    assert_equal "<a href=\"#{Rails.application.routes.url_helpers.admin_service_applications_path(service)}?search%5Bstate%5D=live\">0 live applications</a>",
                 decorator.link_to_live_applications
  end

  def test_link_to_application_plans
    service = Service.new
    service.id = 2

    decorator = ServiceDecorator.new(service)

    assert_equal '<a href="/apiconfig/services/2/application_plans">0 application plans</a> (0 published)',
                 decorator.link_to_application_plans
  end

  def test_published_application_plans
    service = Service.new
    service.id = 2

    decorator = ServiceDecorator.new(service)

    assert_equal [], decorator.published_application_plans
    assert_equal({service: service}, decorator.published_application_plans.context)
  end
end

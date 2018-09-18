require File.expand_path(File.dirname(__FILE__) + '/../../../test_helper')

class Liquid::Drops::NewSignupDropTest < ActiveSupport::TestCase
  include Liquid

  def setup
    @provider = Factory(:provider_account)
  end

  test "returns published account plans" do
    Factory(:account_plan, :issuer => @provider).publish!

    drop = Liquid::Drops::NewSignup.new(@provider,{})

    assert drop.account_plans.is_a?(Array)
    # both default and the one from above are published
    assert_equal 2, drop.account_plans.size
  end

  test "does not return hidden account plans" do
    # hide the default plan
    @provider.account_plans.first.hide!

    drop = Liquid::Drops::NewSignup.new(@provider,{})

    assert_equal 0, drop.account_plans.size
  end

  test "returns services" do
    Factory  :service, :account => @provider
    drop = Liquid::Drops::NewSignup.new(@provider,{})
    assert_equal 2, drop.services.size
  end

  test "#selected_plans method returns only published drops" do
    service = @provider.services.first
    service_plan = Factory( :service_plan, :issuer => service).tap(&:publish!)
    app_plan = Factory( :application_plan, :issuer => service)

    params = { :plans => [ app_plan.id, service_plan.id ]}
    drop = Liquid::Drops::NewSignup.new(@provider, params)

    assert_equal 1, drop.selected_plans.size
    assert_equal service_plan.id, drop.selected_plans.first.id
    assert drop.selected_plans.first.selected?
  end

end

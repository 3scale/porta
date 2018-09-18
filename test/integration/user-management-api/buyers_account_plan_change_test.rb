require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class EnterpriseApiBuyersAccountPlanChangeTest < ActionDispatch::IntegrationTest
  def setup
    @provider = Factory :provider_account, :domain => 'provider.example.com'
    @buyer = Factory(:buyer_account, :provider_account => @provider)
    @buyer.buy! @provider.default_account_plan
    @buyer.reload

    @published_account_plan = Factory :account_plan, :issuer => @provider
    @published_account_plan.publish!

    @hidden_account_plan = Factory :account_plan, :issuer => @provider

    host! @provider.admin_domain
  end

  test 'successful change account plan' do
    put change_plan_admin_api_account_path(@buyer,
                                                :provider_key => @provider.api_key,
                                                "plan_id" => @published_account_plan.id,
                                                :format => :xml)

    assert_response :success

    assert @buyer.bought_account_plan == @published_account_plan

    #TODO: dry plan xml assertion into a helper
    #testing xml response
    xml = Nokogiri::XML::Document.parse(@response.body)
    assert  xml.xpath('.//plan/id').children.first.to_s == @published_account_plan.id.to_s
  end

  test 'change account plan to a non-published one is permitted' do
    put change_plan_admin_api_account_path(@buyer,
                                                :provider_key => @provider.api_key,
                                                "plan_id" => @hidden_account_plan.id,
                                                :format => :xml)

    assert_response :success

    assert_equal @hidden_account_plan, @buyer.bought_account_plan
  end

  test 'change account plan for an inexistent contract replies 404' do
    put change_plan_admin_api_account_path(0,
                                                :provider_key => @provider.api_key,
                                                "plan_id" => 0,
                                                :format => :xml)

    assert_xml_404
  end

  test 'security wise: account plans change is access denied in buyer side' do
    host! @provider.domain
    put change_plan_admin_api_account_path(@buyer,
                                                :provider_key => @provider.api_key,
                                                "plan_id" => @published_account_plan.id,
                                                :format => :xml)
    assert_response :forbidden
  end

end

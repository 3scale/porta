require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class Admin::Api::EndUserPlansTest < ActionDispatch::IntegrationTest
  self.use_transactional_fixtures = true

  def setup
    @provider = FactoryBot.create :provider_account, :domain => 'provider.example.com'
    @service = @provider.first_service!

    @provider.settings.allow_end_users!

    host! @provider.admin_domain
  end

  test 'index (access_token)' do
    FactoryBot.create(:end_user_plan, issuer: @service)
    User.any_instance.stubs(:has_access_to_all_services?).returns(false)
    user  = FactoryBot.create(:member, account: @provider, admin_sections: ['partners'])
    token = FactoryBot.create(:access_token, owner: user, scopes: 'account_management')

    get(admin_api_end_user_plans_path(access_token: token.value, format: :json))
    assert_response :success
    assert_equal 0, JSON.parse(response.body)['end_user_plans'].count

    User.any_instance.expects(:member_permission_service_ids).returns([@service.id]).at_least_once
    get(admin_api_end_user_plans_path(access_token: token.value, format: :json))
    assert_response :success
    assert_equal 1, JSON.parse(response.body)['end_user_plans'].count
  end

  test 'without switch' do
    @provider.settings.deny_end_users!

    get admin_api_end_user_plans_path(:provider_key => @provider.api_key, :format => :xml)

    assert_response :forbidden
  end

  test 'fast track: index' do
    FactoryBot.create(:end_user_plan, :issuer => @service)
    FactoryBot.create(:end_user_plan, :issuer => FactoryBot.create(:service, :account => @provider))

    get admin_api_end_user_plans_path(:provider_key => @provider.api_key, :format => :xml)

    assert_response :success

    assert_xml('/end_user_plans/end_user_plan', 2) do |xml|
      assert_xpath xml, '//id'
    end
  end

  test 'index' do
    FactoryBot.create(:end_user_plan, :issuer => @service)
    FactoryBot.create(:end_user_plan, :issuer => @service)
    FactoryBot.create(:end_user_plan, :issuer => FactoryBot.create(:service, :account => @provider))

    get admin_api_service_end_user_plans_path(@service,
                                              :provider_key => @provider.api_key,
                                              :format => :xml)

    assert_xml('/end_user_plans/end_user_plan/service_id') do |xml|
      assert_equal 2, xml.count
      assert_equal @service.id.to_s, xml.first.text
      assert_equal @service.id.to_s, xml.last.text
    end

    assert_xml('//end_user_plan[@default]', 1)

    assert_response :success
  end

  test 'show' do
    plan = FactoryBot.create(:end_user_plan, :issuer => @service)
    get admin_api_service_end_user_plan_path(@service, plan,
                                             :provider_key => @provider.api_key,
                                             :format => :xml)

    assert_response :success

    assert_xml('/end_user_plan') do |xml|
      assert_xml(xml, '//id', plan.id.to_s)
      assert_xml(xml, '//name', plan.name)
    end

  end

  test 'create' do
    post admin_api_service_end_user_plans_path(@service,
                                                :name => 'name',
                                                :provider_key => @provider.api_key,
                                                :format => :xml)

    assert_response :success

    plan = EndUserPlan.last
    assert plan

    assert_xml('/end_user_plan') do |xml|
      assert_xml(xml, '//id', plan.id.to_s)
      assert_xml(xml, '//name', plan.name)
    end
  end

  test 'update' do
    plan = FactoryBot.create(:end_user_plan, :issuer => @service)

    put admin_api_service_end_user_plan_path(@service, plan,
                                             :name => 'new name',
                                             :provider_key => @provider.api_key,
                                             :format => :xml)
    assert_xml('/end_user_plan') do |xml|
      assert_xml(xml, '//id', plan.id.to_s)
      assert_xml(xml, '//name', 'new name')
    end

    assert_response :success
  end

  test 'default' do
    plan = FactoryBot.create(:end_user_plan, :issuer => @service)

    put default_admin_api_service_end_user_plan_path(@service, plan,
                                                     :provider_key => @provider.api_key,
                                                     :format => :xml)

    assert_response :success
    assert_xml('/end_user_plan[@default="true"]')
  end

end

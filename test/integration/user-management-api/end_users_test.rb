require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class Admin::Api::EndUsersTest < ActionDispatch::IntegrationTest
  disable_transactional_fixtures!

  def setup
    @provider = FactoryBot.create :provider_account, :domain => 'provider.example.com'
    @service = @provider.first_service!

    @provider.settings.allow_end_users!

    host! @provider.admin_domain
    @plan = FactoryBot.create(:end_user_plan, :service => @service)
    ThreeScale::Core::User.stubs(:load).with(@service.backend_id, 'test-subject')
      .returns(stub(username: 'test-subject', plan_id: nil))
    @end_user = EndUser.find(@service, 'test-subject')
  end

  test 'without end users switch' do
    @provider.settings.deny_end_users!

    get admin_api_service_end_user_path(@service, @end_user,
                                         :provider_key => @provider.api_key, :format => :xml)

    assert_response :forbidden
  end

  test 'get end user' do
    get admin_api_service_end_user_path(@service, @end_user,
      :provider_key => @provider.api_key, :format => :xml)

    assert_response :success

    assert_xml('/end_user') do |xml|
      assert_xml xml, '//username', @end_user.username
      assert_xml xml, '//plan_id', @end_user.plan.id.to_s
      assert_xml xml, '//service_id', @end_user.service.id.to_s
    end
  end

  test 'get not existing user' do
    ThreeScale::Core::User.stubs(:load).with(@service.backend_id, '0').returns(nil)
    get admin_api_service_end_user_path(@service, :id => 0,
                                         :provider_key => @provider.api_key, :format => :xml)
    assert_response :not_found
  end

  test 'create end user' do
    FactoryBot.create(:end_user_plan, :service => @service)
    second = FactoryBot.create(:end_user_plan, :service => @service)
    ThreeScale::Core::User.stubs(:load).with(@service.backend_id, 'some-characters').returns(nil)
    post admin_api_service_end_users_path(@service, :username => 'some-characters', :plan_id => second.id,
                                          :provider_key => @provider.api_key, :format => :xml)
    assert_response :success

    assert_xml('/end_user') do |xml|
      assert_xpath xml, '//username', 'some-characters'
      assert_xpath xml, '//plan_id', second.id.to_s
    end
  end

  test 'create duplicate end user' do
    post admin_api_service_end_users_path(@service, :username => @end_user.username, :plan_id => @plan.id,
                                          :provider_key => @provider.api_key, :format => :xml)

    assert_response :unprocessable_entity

    assert_xml('/errors') do |xml|
      assert_xpath xml, '//error', "Username is already used by another EndUser"
    end
  end

  test 'update end user' do
    other = FactoryBot.create(:end_user_plan, :service => @service)
    @end_user.stubs(:new_record?).returns(false)
    put change_plan_admin_api_service_end_user_path(@service, @end_user,
      :plan_id => other, :provider_key => @provider.api_key, :format => :xml)
    assert_response :success

    assert_xml('/end_user') do |xml|
      assert_xml xml, '//username', @end_user.username
      assert_xml xml, '//plan_id', other.id.to_s
    end
  end

  test 'delete end user' do
    delete admin_api_service_end_user_path(@service, @end_user,
                                            :provider_key => @provider.api_key, :format => :xml)
    assert_response :success

    refute @response.body.presence
  end
end

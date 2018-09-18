require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class Admin::Api::WebHooksFailuresTest < ActionDispatch::IntegrationTest

  def setup
    @provider = Factory :provider_account, :domain => 'provider.example.com'
    @buyer = Factory :buyer_account, :provider_account => @provider

    host! @provider.self_domain
  end

  # Access token

  test 'show (access_token)' do
    user  = FactoryGirl.create(:member, account: @provider, admin_sections: ['partners'])
    token = FactoryGirl.create(:access_token, owner: user, scopes: 'account_management')

    Settings::Switch.any_instance.stubs(:allowed?).returns(true)
    # member should not be able to work with webhooks at all
    get(admin_api_webhooks_failures_path, access_token: token.value)
    assert_response :forbidden

    user.role = 'admin'
    user.save!
    get(admin_api_webhooks_failures_path, access_token: token.value)
    assert_response :success

    Settings::Switch.any_instance.stubs(:allowed?).returns(false)
    get(admin_api_webhooks_failures_path, access_token: token.value)
    assert_response :forbidden
  end

  test 'destroy (access_token)' do
    user  = FactoryGirl.create(:admin, account: @provider, admin_sections: ['partners'])
    token = FactoryGirl.create(:access_token, owner: user, scopes: 'account_management')
    Settings::Switch.any_instance.stubs(:allowed?).returns(true)

    delete(admin_api_webhooks_failures_path, access_token: token.value)
    assert_response :success
  end

  # Provider key

  test '#show' do
    WebHookFailures.add @provider.id, "FakedException", 'uuid', 'url', '<fake><xml/></fake>'

    get("/admin/api/webhooks/failures.xml", :provider_key => @provider.api_key)

    assert_response :success
    assert_equal @response.body,  WebHookFailures.new(@provider.id).to_xml
  end

  test '#delete empties the list if no time passed' do
    WebHookFailures.new(@provider.id).add("id" => "2")

    delete("/admin/api/webhooks/failures.xml", :provider_key => @provider.api_key)

    assert_response :success
    assert_empty_xml @response.body
    assert WebHookFailures.new(@provider.id).empty?
  end

  test '#delete deletes elements with time less than or equal the time passed' do
    WebHookFailures.new(@provider.id).add("id" => "2", time: '2010-01-01')
    WebHookFailures.new(@provider.id).add("id" => "3", time: '2011-01-01')

    delete("/admin/api/webhooks/failures.xml", :provider_key => @provider.api_key,
                "time" => '2010-01-01')

    assert_response :success
    assert_empty_xml @response.body
    assert_equal '3', WebHookFailures.new(@provider.id).first.id
  end

end

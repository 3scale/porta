require 'test_helper'
require 'webmock/minitest'


class HerokuTest < ActiveSupport::TestCase

  test 'should sync heroku data' do
    provider = FactoryGirl.create(:provider_account)
    admin = provider.first_admin
    admin.update_column(:state, "pending")


    heroku_id = 'foo'
    provider.settings.update_column(:heroku_id, heroku_id)

    owner_email = 'bar@example.com'

    body = {  callback_url: 'https://api.heroku.com/vendor/apps/foo',
              config: {'THREESCALE_PROVIDER_KEY' => '123456'},
              domains: %w[foo.example.com],
              id: 'foo',
              logplex_token: '654321',
              name: 'bar',
              owner_email: owner_email,
              region: 'example-service::us-east-1'
            }.to_json

    stub_request(:get, "https://api.heroku.com/vendor/apps/foo?").with(:headers => {'Accept'=>'*/*', 'Authorization'=>Base64.strict_encode64("#{Heroku.addon_name}:#{Heroku.password}")}).to_return(status: 200, body: body, headers: {})

    provider.reload

    ThreeScale::Analytics::UserClassifier.any_instance.stubs(has_3scale_email?: true)

    Heroku.sync(provider)

    assert_equal 'bar', provider.settings.heroku_name
    assert_equal owner_email, provider.users.admins.first.email
    assert_equal 'Internal', provider.extra_fields['account_type']
  end

  test 'should raise error if heroku api returns something diferent of 200 or 404' do
    provider = FactoryGirl.create(:provider_account)
    heroku_id = 'foo'
    provider.settings.update_column(:heroku_id, heroku_id)

    stub_request(:get, "https://api.heroku.com/vendor/apps/foo?").with(:headers => {'Accept'=>'*/*', 'Authorization'=>Base64.strict_encode64("#{Heroku.addon_name}:#{Heroku.password}")}).to_return(status: 418, body: 'the fake body', headers: {})

    assert_raise Heroku::SyncError do
      Heroku.sync(provider)
    end
  end

  test 'should return false isnt a provider account' do
    buyer = FactoryGirl.create(:buyer_account)
    refute Heroku.sync(buyer)
  end

  test 'should return false isnt a heroku account' do
    provider = FactoryGirl.create(:provider_account)
    refute Heroku.sync(provider)
    provider.reload
    assert provider.settings.heroku_id.nil?
    assert provider.settings.heroku_name.nil?
  end

  test 'sso_url should return false if heroku is false' do
    account = mock()
    account.stubs(:heroku? => false)
    refute Heroku.sso_url(account)
  end

  test 'sso_url should return a url' do
    account = mock()
    settings = mock()
    settings.stubs(heroku_name: 'foo')
    account.stubs(settings: settings, heroku?: true)

    assert_equal "https://api.heroku.com/myapps/foo/addons/#{Heroku.addon_name}", Heroku.sso_url(account)
  end

  test 'sso_url should include the return_to' do
    account = mock()
    settings = mock()
    settings.stubs(heroku_name: 'foo')
    account.stubs(settings: settings, heroku?: true)

    assert_equal "https://api.heroku.com/myapps/foo/addons/#{Heroku.addon_name}?return_to=/lalala", Heroku.sso_url(account, '/lalala')
  end
end

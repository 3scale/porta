require 'test_helper'

class Admin::Api::NginxesControllerTest < ActionController::TestCase
  setup do
    Logic::RollingUpdates.stubs(skipped?: true)
  end

  test 'show' do
    provider = FactoryBot.create(:provider_account, domain: 'provider.example.com')
    host! provider.admin_domain

    get :show, format: :zip, provider_key: provider.api_key

    assert_response :success
    assert_equal 'application/zip', response.content_type
    assert_includes response.headers, 'Content-Transfer-Encoding', 'Content-Disposition'
    assert_equal 'attachment; filename="proxy_configs.zip"', response['Content-Disposition']
    assert_equal 'binary', response['Content-Transfer-Encoding']

    Zip::InputStream.open(StringIO.new(response.body)) do |zip|
      assert zip.get_next_entry
    end
  end

  test 'spec returns a json' do
    provider = FactoryBot.create(:provider_account, domain: 'provider.example.com')
    host! provider.admin_domain

    get :spec, format: :json, provider_key: provider.api_key

    assert_response :success
    assert_equal provider.id, ActiveSupport::JSON.decode(@response.body)['id'].to_i
  end

end

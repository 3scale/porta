require 'test_helper'

class Apicast::UserSourceTest < ActiveSupport::TestCase
  def setup
    @user = FactoryBot.build_stubbed(:simple_user)
    @source = Apicast::UserSource.new(@user)
  end

  def test_attributes_for_proxy
    assert attributes = @source.attributes_for_proxy
  end

  def test_id
    @user.id = 1000
    @user.account.id = 42

    assert_equal 42, @source.id
  end

  def test_services
    proxy = FactoryBot.build_stubbed(:proxy)
    service = FactoryBot.build_stubbed(:simple_service, proxy: proxy)
    services = [ service ]
    @user.stubs(accessible_services: services)

    assert subject = @source.services.presence, 'none services'
    assert_equal services.size, subject.size

    service.stubs(updated_at: Time.now)
    assert_equal service.updated_at, @source.attributes_for_proxy['services'][0]['updated_at']

    assert proxy_attributes = subject.first.proxy

    assert_equal proxy.hosts, proxy_attributes.hosts
    assert_equal proxy.backend.stringify_keys, proxy_attributes.backend.to_h
  end
end

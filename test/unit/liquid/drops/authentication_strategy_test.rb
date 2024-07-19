require 'test_helper'

class Liquid::Drops::AuthenticationStrategyTest < ActiveSupport::TestCase
  include Liquid

  def setup
    provider = FactoryBot.create :provider_account
    provider.settings.update(cas_server_url: 'https://cas.example.com')
    strategy = Authentication::Strategy::Cas.new provider
    @drop = Drops::AuthenticationStrategy::Cas.new strategy
  end

  test '#login_url' do
    assert_equal "https://cas.example.com/login?service=http%3A%2F%2Fcompany1.com%2Fsession%2Fcreate", @drop.login_url
  end
end

# frozen_string_literal: true

require 'test_helper'

class ProxyConfigDecoratorTest < Draper::TestCase
  test '#user_display_name' do
    user = FactoryBot.build(:admin)
    proxy_config = FactoryBot.build(:proxy_config, user: user)
    assert_equal user.decorate.display_name, proxy_config.decorate.user_display_name

    proxy_config_without_user = ProxyConfig.new
    assert_nil proxy_config_without_user.decorate.user_display_name
  end
end

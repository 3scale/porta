require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  attr_accessor :current_user
  delegate :can?, to: :ability

  def test_link_to_export_widget_for
    self.current_user = FactoryBot.build_stubbed(:member, account: account)
    link = link_to_export_widget_for('Accounts')
    assert_nil link

    self.current_user = FactoryBot.build_stubbed(:admin, account: account)
    link = link_to_export_widget_for('Accounts')
    assert_match /a/, link
  end

  def test_css_class
    assert_equal 'some class', css_class('some', 'class')

    assert_equal 'yes maybe', css_class('yes' => true, 'no' => false, maybe: 'yeah')

    assert_equal 'one two three', css_class('one', ['two'], three: true)
  end

  class AssetHostTest < ApplicationHelperTest
    setup do
      @request = ActionDispatch::TestRequest.create
      @asset_host = 'cdn.3scale.test.localhost'
    end

    attr_reader :request

    test 'asset host is not configured' do
      Rails.configuration.asset_host = nil
      Rails.configuration.three_scale.asset_host = @asset_host

      result = rails_asset_host_url

      assert_equal '', result
    end

    test "asset host is configured but it's value is empty" do
      Rails.configuration.asset_host = -> {}
      Rails.configuration.three_scale.asset_host = ''

      result = rails_asset_host_url

      assert_equal '', result
    end

    test 'asset host is configured and has a proper value' do
      Rails.configuration.asset_host = -> {}
      Rails.configuration.three_scale.asset_host = @asset_host

      result = rails_asset_host_url

      assert_equal "#{request.protocol}#{@asset_host}", result
    end
  end

  private

  def ability
    Ability.new(current_user)
  end

  def account
    @account ||= FactoryBot.build_stubbed(:simple_provider)
  end
end

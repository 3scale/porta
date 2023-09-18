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
      @full_asset_host = "https://#{@asset_host}"
    end

    attr_reader :request

    test 'asset host is not configured' do
      Rails.configuration.stubs(:asset_host).returns(nil)

      result = rails_asset_host_url

      assert_equal '', result
    end

    test "asset host is configured but it's value is empty" do
      Rails.configuration.stubs(:asset_host).returns(-> {})
      Rails.configuration.three_scale.stubs(:asset_host).returns('')

      result = rails_asset_host_url

      assert_equal '', result
    end

    test 'asset host is configured and has a proper value' do
      Rails.configuration.stubs(:asset_host).returns(-> {})
      Rails.configuration.three_scale.stubs(:asset_host).returns(@asset_host)

      result = rails_asset_host_url

      assert_equal "#{request.protocol}#{@asset_host}", result
    end

    test 'asset host is configured and set to a full URL with protocol' do
      Rails.configuration.stubs(:asset_host).returns(-> {})
      Rails.configuration.three_scale.stubs(:asset_host).returns(@full_asset_host)

      result = rails_asset_host_url

      assert_equal @full_asset_host, result
    end

    test 'docs base url' do
      ThreeScale.config.stubs(onpremises: false)
      assert_equal 'https://access.redhat.com/documentation/en-us/red_hat_3scale/2-saas/html', docs_base_url
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

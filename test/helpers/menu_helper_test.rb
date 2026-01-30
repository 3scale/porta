# frozen_string_literal: true

require 'test_helper'

class MenuHelperTest < ActionView::TestCase
  def setup
    @provider = FactoryBot.create(:provider_account)
    @ability = Ability.new(@provider.admins.first)
  end

  test 'switch_link with finance globally disabled' do
    expects(:forcibly_denied_switch?).with(:finance).returns(true)
    assert_nil switch_link('Billing', root_path, switch: :finance, upgrade_notice: true)
  end

  test 'switch_link with finance globally enabled' do
    expects(:forcibly_denied_switch?).with(:finance).returns(false)
    link = switch_link('Billing', root_path, switch: :finance, upgrade_notice: true)
    assert_equal upgrade_notice_link(:finance, 'Billing'), link
  end

  test 'forcibly_denied_switch?' do
    Settings.stubs(globally_denied_switches: [])
    assert @provider.settings.finance.denied?
    assert_not forcibly_denied_switch?(:finance)

    Settings.stubs(globally_denied_switches: [:finance])
    assert_not forcibly_denied_switch?(:finance)
  end

  test 'forcibly_denied_switch? for master' do
    ThreeScale.config.stubs(onpremises: false)
    @provider = master_account
    assert @provider.settings.finance.denied?
    assert_not forcibly_denied_switch?(:finance)

    ThreeScale.config.stubs(onpremises: true)
    assert @provider.settings.finance.denied?
    assert forcibly_denied_switch?(:finance)
  end

  test '#vertical_nav_hidden?' do
    %i[dashboard products backend_apis quickstarts].each do |menu|
      expects(:active_menu).returns(menu)
      assert vertical_nav_hidden?
    end

    %i[personal account audience buyers finance cms site settings apis applications active_docs serviceadmin monitoring backend_api].each do |menu|
      expects(:active_menu).returns(menu)
      assert_not vertical_nav_hidden?
    end
  end

  test '#masthead_props' do
    expects(:context_selector_props).returns([])
    expects(:current_user).returns(FactoryBot.create(:simple_user)).twice
    expects(:documentation_items).returns([])
    expects(:vertical_nav_hidden?).returns(true)

    data = masthead_props.as_json

    # Assert app/javascript/src/Navigation/components/Masthead.tsx#Props
    assert_not_nil data['brandHref']
    assert_not_nil data['contextSelectorProps']
    assert_not_nil data['currentAccount']
    assert_not_nil data['currentUser']
    assert_not_nil data['documentationMenuItems']
    assert_not_nil data['impersonating']
    assert_not_nil data['signOutHref']
    assert_not_nil data['verticalNavHidden']
  end

  test '#context_selector_props' do
    expects(:active_menu).returns(:dashboard).at_least_once
    expects(:current_user).returns(FactoryBot.create(:simple_user))
    data = context_selector_props.as_json

    # Assert app/javascript/src/Navigation/components/ContextSelector.tsx#Props
    assert_not_nil data['toggle']
    assert_not_nil data['menuItems']
  end

  test '#documentation_items' do
    ThreeScale.stubs(:saas?).returns(false)
    Features::QuickstartsConfig.stubs(enabled?: false)
    assert_equal documentation_items.length, 3

    ThreeScale.stubs(:saas?).returns(true)
    Features::QuickstartsConfig.stubs(enabled?: false)
    assert_equal documentation_items.length, 4

    ThreeScale.stubs(:saas?).returns(false)
    Features::QuickstartsConfig.stubs(enabled?: true)
    assert_equal documentation_items.length, 4

    ThreeScale.stubs(:saas?).returns(true)
    Features::QuickstartsConfig.stubs(enabled?: true)
    assert_equal documentation_items.length, 5
  end

  protected

  def current_account
    @provider
  end

  def can?(*args)
    @ability.can?(*args)
  end
end

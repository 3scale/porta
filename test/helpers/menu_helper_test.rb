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
    %i[dashboard products backend_apis quick_starts].each do |menu|
      expects(:active_menu).returns(menu)
      assert vertical_nav_hidden?
    end

    %i[personal account audience buyers finance cms site settings apis applications active_docs serviceadmin monitoring backend_api].each do |menu|
      expects(:active_menu).returns(menu)
      assert_not vertical_nav_hidden?
    end
  end

  protected

  def current_account
    @provider
  end

  def can?(*args)
    @ability.can?(*args)
  end
end

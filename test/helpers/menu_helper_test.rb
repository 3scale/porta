require 'test_helper'

class MenuHelperTest < ActionView::TestCase

  def setup
    @provider = FactoryGirl.create(:provider_account)
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
    refute forcibly_denied_switch?(:finance)

    Settings.stubs(globally_denied_switches: [:finance])
    refute forcibly_denied_switch?(:finance)
  end

  test 'forcibly_denied_switch? for master' do
    ThreeScale.config.stubs(onpremises: false)
    @provider = master_account
    assert @provider.settings.finance.denied?
    refute forcibly_denied_switch?(:finance)

    ThreeScale.config.stubs(onpremises: true)
    assert @provider.settings.finance.denied?
    assert forcibly_denied_switch?(:finance)
  end

  protected

  def current_account
    @provider
  end

  def can?(*args)
    @ability.can?(*args)
  end
end

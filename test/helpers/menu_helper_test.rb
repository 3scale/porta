require 'test_helper'

class MenuHelperTest < ActionView::TestCase
  def setup
    @provider = FactoryBot.create(:provider_account)
  end

  attr_reader :provider

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

  test 'api_selector_services for tenant logged in without api_as_product' do
    FactoryBot.create(:simple_service, account: provider)
    FactoryBot.create(:simple_service, account: provider, state: Service::DELETE_STATE)

    rolling_updates_on
    rolling_update(:api_as_product, enabled: false)

    assert_equal provider.accessible_services.size, api_selector_services.size
    api_selector_services.each do |api_decorated|
      assert_equal ServiceDecorator, api_decorated.class
      assert_includes provider.accessible_services.pluck(:id), api_decorated.id
    end
  end

  test 'api_selector_services for tenant logged in with api_as_product' do
    FactoryBot.create(:simple_service, account: provider)
    FactoryBot.create(:simple_service, account: provider, state: Service::DELETE_STATE)
    FactoryBot.create(:backend_api, account: provider)
    FactoryBot.create(:backend_api, account: provider, state: BackendApi::DELETED_STATE)

    rolling_updates_on
    rolling_update(:api_as_product, enabled: true)

    services_decorated, backend_apis_decorated = api_selector_services.partition { |api_decorated| api_decorated.class == ServiceDecorator }
    assert_equal provider.accessible_services.size, services_decorated.size
    assert_equal provider.backend_apis.accessible.size, backend_apis_decorated.size
    assert_same_elements provider.accessible_services.pluck(:id), services_decorated.map(&:id)
    assert_same_elements provider.backend_apis.accessible.pluck(:id), backend_apis_decorated.map(&:id)
    assert backend_apis_decorated.all? { |api_decorated| api_decorated.class == BackendApiDecorator }
  end

  test 'api_selector_services if not logged in' do
    @current_account = nil
    assert_empty api_selector_services
  end

  test 'api_selector_services in developer portal' do
    @current_account = FactoryBot.create(:simple_buyer, provider_account: provider)
    assert_empty api_selector_services
  end


  protected

  def current_user
    @current_user ||= current_account.try!(:admin_user)
  end

  def current_account
    return @current_account if defined? @current_account
    @current_account = @provider
  end

  def ability
    @ability ||= Ability.new(current_user)
  end

  def can?(*args)
    ability.can?(*args)
  end
end
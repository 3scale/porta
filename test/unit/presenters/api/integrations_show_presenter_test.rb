require 'test_helper'

class Api::IntegrationsShowPresenterTest < ActiveSupport::TestCase

  Presenter = Api::IntegrationsShowPresenter

  def setup
    @proxy = FactoryBot.create(:simple_proxy)
  end

  def test_initialize
    assert Presenter.new(@proxy)
  end

  def test_memoized_methods
    presenter = Presenter.new(@proxy)

    presenter.expects(:any_configs?).with(:sandbox).once
    presenter.expects(:any_configs?).with(:production).once
    presenter.any_sandbox_configs?
    presenter.any_production_configs?

    presenter.expects(:any_configs?).with(:sandbox).never
    presenter.expects(:any_configs?).with(:production).never
    presenter.any_sandbox_configs?
    presenter.any_production_configs?
  end

  def test_any_sandbox_configs?
    refute Presenter.new(@proxy).any_sandbox_configs?
    FactoryBot.create(:proxy_config, proxy: @proxy, environment: 'sandbox')
    assert Presenter.new(@proxy).any_sandbox_configs?
  end

  def test_any_production_configs?
    refute Presenter.new(@proxy).any_production_configs?
    FactoryBot.create(:proxy_config, proxy: @proxy, environment: 'production')
    assert Presenter.new(@proxy).any_production_configs?
  end

  def test_environments_have_same_config?
    refute Presenter.new(@proxy).environments_have_same_config?

    FactoryBot.create(:proxy_config, proxy: @proxy, environment: 'sandbox', version: 2)
    FactoryBot.create(:proxy_config, proxy: @proxy, environment: 'production', version: 1)
    refute Presenter.new(@proxy).environments_have_same_config?

    FactoryBot.create(:proxy_config, proxy: @proxy, environment: 'production', version: 2)
    assert Presenter.new(@proxy).environments_have_same_config?
  end

  def test_state_modifier
    @proxy.account.stubs(:provider_can_use?).with(:api_as_product).returns(false)

    assert_equal 'is-untested', Presenter.new(@proxy).test_state_modifier

    @proxy.api_test_success = true
    assert_equal 'is-successful', Presenter.new(@proxy).test_state_modifier

    @proxy.api_test_success = false
    assert_equal 'is-erroneous', Presenter.new(@proxy).test_state_modifier
  end

  test 'state_modifier for apiap' do
    @proxy.account.stubs(:provider_can_use?).with(:api_as_product).returns(true)

    assert_equal 'is-untested', Presenter.new(@proxy).test_state_modifier

    @proxy.api_test_success = true
    assert_equal 'is-untested', Presenter.new(@proxy).test_state_modifier

    @proxy.api_test_success = false
    assert_equal 'is-untested', Presenter.new(@proxy).test_state_modifier
  end

  def test_production_proxy_endpoint
    FactoryBot.create(:proxy_config, proxy: @proxy, environment: 'production')
    assert_equal @proxy.default_production_endpoint, presenter.production_proxy_endpoint
  end

  def test_staging_proxy_endpoint
    FactoryBot.create(:proxy_config, proxy: @proxy, environment: 'sandbox')
    assert_equal @proxy.default_staging_endpoint, presenter.staging_proxy_endpoint
  end

  protected

  # @return Api::IntegrationsShowPresenter
  def presenter
    Presenter.new(@proxy)
  end
end

# frozen_string_literal: true

require 'test_helper'

class ServicesActionsPresenterTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  def setup
    @provider = FactoryBot.create(:simple_provider)
    user = FactoryBot.create(:member, account: @provider)
    @presenter = ServiceActionsPresenter.new(user)
    Ability.any_instance.expects(:can?).returns(false).at_least_once
  end

  attr_reader :provider, :presenter

  test "#actions returns the right links according to user permissions" do
    product = FactoryBot.create(:simple_service, account: provider)
    id = product.id

    stub_can(:manage, :plans) do
      actions = presenter.actions(product)
      assert_equal %w[Edit Overview Applications ActiveDocs Integration], actions.map { _1[:name] }
      assert_equal %W[
        /apiconfig/services/#{id}/edit
        /apiconfig/services/#{id}
        /apiconfig/services/#{id}/application_plans
        /apiconfig/services/#{id}/api_docs
        /apiconfig/services/#{id}/integration
      ], actions.map { _1[:path] }
    end

    stub_can(:manage, :monitoring) do
      actions = presenter.actions(product)
      assert_equal %w[Analytics], actions.map { _1[:name] }
      assert_equal %W[/services/#{id}/stats/usage], actions.map { _1[:path] }
    end

    stub_can(:manage, :applications) do
      actions = presenter.actions(product)
      assert_equal %w[Applications], actions.map { _1[:name] }
      assert_equal %W[/apiconfig/services/#{id}/applications], actions.map { _1[:path] }
    end

    stub_can(:manage, :policy_registry) do
      actions = presenter.actions(product)
      assert_equal %w[Policies], actions.map { _1[:name] }
      assert_equal %W[/apiconfig/services/#{id}/policies/edit], actions.map { _1[:path] }
    end

    Ability.any_instance.expects(:can?).returns(true).at_least_once
    actions = presenter.actions(product)
    assert_equal %w[Edit Overview Analytics Applications ActiveDocs Integration], actions.map { _1[:name] }
    assert_equal %W[
      /apiconfig/services/#{id}/edit
      /apiconfig/services/#{id}
      /services/#{id}/stats/usage
      /apiconfig/services/#{id}/applications
      /apiconfig/services/#{id}/api_docs
      /apiconfig/services/#{id}/integration
    ], actions.map { _1[:path] }
  end

  private

  def stub_can(action, object)
    Ability.any_instance.stubs(:can?).with(action, object).returns(true)
    yield if block_given?
    Ability.any_instance.stubs(:can?).with(action, object).returns(false)
  end
end

# frozen_string_literal: true

require 'test_helper'

class Provider::Admin::ApplicationsNewPresenterTest < ActiveSupport::TestCase

  Presenter = Provider::Admin::ApplicationsNewPresenter

  def setup
    @provider = FactoryBot.create(:provider_account)
    @user = FactoryBot.create(:simple_admin)
  end

  attr_reader :provider, :user, :cinstance

  test 'new_application_form_data' do
    presenter = Presenter.new(provider: provider, user: user)
    form_data = presenter.new_application_form_data

    expected_keys = %i[create-application-path create-application-plan-path create-service-plan-path service-subscriptions-path service-plans-allowed defined-fields most-recently-created-buyers buyers-count most-recently-updated-products products-count]
    unexpected_keys = %i[product buyer errors]

    assert_same_elements expected_keys, form_data.keys
    unexpected_keys.each { |key| assert_does_not_contain form_data.keys, key }
  end

  test 'new_application_form_data with errors' do
    cinstance = FactoryBot.create(:simple_cinstance)
    cinstance.expects(:errors).returns(['error'])
    presenter = Presenter.new(provider: provider, user: user, cinstance: cinstance)
    form_data = presenter.new_application_form_data

    assert form_data.key? :errors
    assert_equal form_data[:errors], ['error'].to_json
  end
end

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

    assert form_data.key? :"create-application-path"
    assert form_data.key? :"create-application-plan-path"
    assert form_data.key? :"service-subscriptions-path"
    assert form_data.key? :"service-plans-allowed"
    assert form_data.key? :"defined-fields"
    assert form_data.key? :"most-recently-created-buyers"
    assert form_data.key? :"buyers-count"
    assert form_data.key? :"most-recently-updated-products"
    assert form_data.key? :"products-count"

    assert_not form_data.key? :product
    assert_not form_data.key? :errors
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

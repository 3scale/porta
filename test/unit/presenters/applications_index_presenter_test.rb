# frozen_string_literal: true

require 'test_helper'

class ApplicationsIndexPresenterTest < ActionView::TestCase
  def setup
    @buyer = FactoryBot.create(:simple_buyer)
  end

  attr_reader :buyer

  test "new application path when no applications" do
    presenter = initialize_presenter({ buyer: buyer })

    assert buyer.bought_cinstances.size.zero?
    assert_equal new_admin_buyers_account_application_path(buyer), presenter.create_application_link_href
  end

  test "new application path when multiple applications enabled" do
    FactoryBot.create(:simple_cinstance, user_account: buyer)
    Ability.any_instance.expects(:can?).with(:admin, :multiple_applications).returns(true).once
    Ability.any_instance.expects(:can?).with(:see, :multiple_applications).returns(true).once

    presenter = initialize_presenter({ buyer: buyer })

    assert buyer.bought_cinstances.size.positive?
    assert_equal new_admin_buyers_account_application_path(buyer), presenter.create_application_link_href
  end

  test "new application path when upgrade needed" do
    FactoryBot.create(:simple_cinstance, user_account: buyer)
    Ability.any_instance.expects(:can?).with(:admin, :multiple_applications).returns(true).once
    Ability.any_instance.expects(:can?).with(:see, :multiple_applications).returns(false).once

    presenter = initialize_presenter({ buyer: buyer })

    assert_not buyer.bought_cinstances.size.zero?
    assert_equal admin_upgrade_notice_path(:multiple_applications), presenter.create_application_link_href
  end

  test "new application path when single application" do
    FactoryBot.create(:simple_cinstance, user_account: buyer)
    Ability.any_instance.expects(:can?).with(:admin, :multiple_applications).returns(false)

    presenter = initialize_presenter({ buyer: buyer })

    assert_not buyer.bought_cinstances.size.zero?
    assert_nil presenter.create_application_link_href
  end

  def initialize_presenter(opts)
    ApplicationsIndexPresenter.new(application_plans: opts[:application_plans],
                                   accessible_services: opts[:accessible_services],
                                   service: opts[:service],
                                   provider: opts[:provider],
                                   accessible_plans: opts[:accessible_plans],
                                   buyer: opts[:buyer],
                                   user: opts[:user],
                                   params: opts[:params] || {})
  end
end

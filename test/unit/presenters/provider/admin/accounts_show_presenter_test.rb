require 'test_helper'

class Provider::Admin::AccountsShowPresenterTest < ActiveSupport::TestCase

  Presenter = Provider::Admin::AccountsShowPresenter

  def test_initialize
    assert Presenter.new(mock('account'), mock('user'))
  end

  def test_edit_link_not_shown_user_cannot_update_account
    account = mock('account')
    ability = mock('ability')
    presenter = Presenter.new(account, mock('user'))
    ability.expects(:can?).with(:update, account).returns(false)
    presenter.expects(:ability).returns(ability)
    refute presenter.show_edit_account_link?
  end

  def test_edit_link_shown
    account = mock('account')
    ability = mock('ability')
    presenter = Presenter.new(account, mock('user'))
    ability.expects(:can?).with(:update, account).returns(true)
    presenter.expects(:ability).returns(ability)
    assert presenter.show_edit_account_link?
  end

  def test_cancellation_part_not_shown_onprem
    presenter = Presenter.new(mock('account'), mock('user'))
    ThreeScale.config.stubs(onpremises: true)
    refute presenter.show_cancellation_section?
  end

  def test_cancellation_part_not_shown_user_cannot_destroy_account
    account = mock('account')
    ability = mock('ability')
    presenter = Presenter.new(account, mock('user'))
    ability.expects(:can?).with(:destroy, account).returns(false)
    presenter.expects(:multitenant?).returns(true)
    presenter.expects(:ability).returns(ability)
    refute presenter.show_cancellation_section?
  end

  def test_cancellation_part_shown
    account = mock('account')
    ability = mock('ability')
    presenter = Presenter.new(account, mock('user'))
    ability.expects(:can?).with(:destroy, account).returns(true)
    presenter.expects(:multitenant?).returns(true)
    presenter.expects(:ability).returns(ability)
    assert presenter.show_cancellation_section?
  end

  def test_show_plan_section_saas
    ThreeScale.config.stubs(onpremises: false)
    presenter = Presenter.new(mock('account'), mock('user'))
    presenter.expects(:multitenant?).returns(true)
    assert presenter.show_plan_section?

    presenter.expects(:multitenant?).returns(false)
    refute presenter.show_plan_section?
  end

  def test_show_plan_section_on_premises
    ThreeScale.config.stubs(onpremises: true)
    presenter = Presenter.new(mock('account'), mock('user'))
    presenter.expects(:multitenant?).returns(true)
    refute presenter.show_plan_section?

    presenter.expects(:multitenant?).returns(false)
    refute presenter.show_plan_section?
  end

  def test_redhat_customer_verification_enabled_not_shown_onprem
    presenter = Presenter.new(mock('account'), mock('user'))
    ThreeScale.config.stubs(onpremises: false)
    assert presenter.redhat_customer_verification_enabled?
    ThreeScale.config.stubs(onpremises: true)
    refute presenter.redhat_customer_verification_enabled?
  end
end

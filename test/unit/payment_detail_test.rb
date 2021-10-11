require 'test_helper'

class PaymentDetailTest < ActiveSupport::TestCase

  setup do
    @account = FactoryBot.create(:simple_account)
    @payment_detail = FactoryBot.create(:payment_detail, account: @account)
    @empty_attributes = { buyer_reference: nil, payment_service_reference: nil, credit_card_partial_number: nil, credit_card_expires_on: nil }
  end

  test 'aliases credit_card_auth_code' do
    assert_equal @payment_detail.buyer_reference, @payment_detail.credit_card_auth_code
  end

  test 'aliases credit_card_authorize_net_payment_profile_token' do
    assert_equal @payment_detail.payment_service_reference, @payment_detail.credit_card_authorize_net_payment_profile_token
  end

  test '#any_values?' do
    assert @payment_detail.any_values?

    @payment_detail.assign_attributes @empty_attributes
    refute @payment_detail.any_values?
  end

  test '#notify_changes? default is true' do
    assert @payment_detail.notify_changes?
  end

  test '#do_not_notify' do
    @payment_detail.do_not_notify
    refute @payment_detail.notify_changes?
  end

  test '#changed_for_autosave?' do
    # no changes
    refute @payment_detail.changed_for_autosave?

    # persisted / changed / not empty
    @payment_detail.credit_card_partial_number = '1234'
    assert @payment_detail.changed_for_autosave?

    # persisted / changed / empty
    @payment_detail.assign_attributes @empty_attributes
    assert @payment_detail.changed_for_autosave?

    # new_record / not empty
    payment_detail = FactoryBot.build(:payment_detail, account: @account)
    assert payment_detail.changed_for_autosave?

    # new_record / empty
    payment_detail = FactoryBot.build(:payment_detail, { account: @account }.merge(@empty_attributes))
    refute payment_detail.changed_for_autosave?
  end

  test 'audits' do
    PaymentDetail.with_synchronous_auditing do
      payment_detail = FactoryBot.create(:payment_detail, account: @account, credit_card_partial_number: '1111')

      audit = payment_detail.audits.last
      assert_equal 'create', audit.action

      payment_detail.credit_card_partial_number = '2222'
      payment_detail.save

      audit = payment_detail.audits.last
      assert_equal 'update', audit.action
      assert_equal ['1111', '2222'], audit.audited_changes['credit_card_partial_number']
    end
  end

  class NotifierTest < ActiveSupport::TestCase

    def setup
      @cc_attributes = {
        credit_card_auth_code: 'auth_code',
        credit_card_partial_number: '1111',
        credit_card_expires_on: Date.parse('2020-08-01'),
        credit_card_authorize_net_payment_profile_token: 'auth_net_token'
      }
    end

    test 'does not notify on copy from account' do
      account = FactoryBot.create(:simple_account)
      refute PaymentDetail.where(account_id: account.id).exists?
      Account.where(id: account.id).update_all(@cc_attributes)
      account.reload
      PaymentDetail::CreditCardChangeNotifier.any_instance.expects(:call).never
      assert account.payment_detail.persisted?
    end

    test 'notify if new changes' do
      account = FactoryBot.create(:simple_account)

      PaymentDetail::CreditCardChangeNotifier.any_instance.expects(:call)
      account.credit_card_auth_code = '12345'
      account.save
      assert_equal '12345', account.payment_detail.buyer_reference
    end
  end
end

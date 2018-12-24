# frozen_string_literal: true

require 'test_helper'

class InvoiceFriendlyIdServiceTest < ActiveSupport::TestCase
  disable_transactional_fixtures!

  setup do
    provider_account = FactoryBot.create(:provider_with_billing)
    provider_account.billing_strategy.update_attribute(:numbering_period, 'yearly')
    FactoryBot.create(:invoice_counter, provider_account: provider_account, invoice_prefix: Time.now.year.to_s)
    @invoice = FactoryBot.create(:invoice, provider_account: provider_account)
    @service = InvoiceFriendlyIdService.new(@invoice)
  end

  test 'updates the invoice friendly_id' do
    assert_equal "#{Time.now.year}-00000001", @invoice.friendly_id
  end

  test 'keep existing invoice friendly_id' do
    @invoice.update_attribute(:friendly_id, '2018-00000009')
    assert_equal '2018-00000009', @service.call
  end

  test 'perform async when it fails' do
    @service.expects(:update_friendly_id).raises(ActiveRecord::ActiveRecordError.new)
    InvoiceFriendlyIdWorker.expects(:perform_async).with(@invoice.id)
    @service.call
  end

  test 'returns current friendly_id while enqueued to perform async' do
    current_friendly_id = @invoice.friendly_id
    assert_equal current_friendly_id, @service.call_async
  end

  test 'raises tagged exception' do
    exception = ActiveRecord::ActiveRecordError.new
    @service.expects(:update_friendly_id).raises(exception)
    assert_raises InvoiceFriendlyIdService::CannotUpdateFriendlyIdException do
      @service.call!
    end
  end

  protected

  def default_friendly_id
    @service.send(:default_friendly_id)
  end
end

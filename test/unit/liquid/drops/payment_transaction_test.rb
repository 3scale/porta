require 'test_helper'

class Liquid::Drops::PaymentTransactionDropTest < ActiveSupport::TestCase
  include Liquid

  def setup
    @payment_transaction = Factory.build(:payment_transaction)
    @drop = Drops::PaymentTransaction.new(@payment_transaction)
  end

  should 'be success' do
    @payment_transaction.stubs :success? => true
    assert @drop.success?
  end

  should 'not be success' do
    @payment_transaction.stubs :success? => false
    assert !@drop.success?
  end

  should 'returns created_at' do
    assert_equal(@drop.created_at, @payment_transaction.created_at)
  end

  should 'returns reference' do
    assert_equal(@drop.reference, @payment_transaction.reference)
  end

  should 'returns message' do
    assert_equal(@drop.message, @payment_transaction.message)
  end

  should 'returns amount' do
    assert_equal(@drop.amount, @payment_transaction.amount.to_s)
  end

  should 'returns currency' do
    assert_equal(@drop.currency, @payment_transaction.currency)
  end


end

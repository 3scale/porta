module PaymentTransactionsRepresenter
  include ThreeScale::JSONRepresenter

  wraps_collection :payment_transactions

  items extend: PaymentTransactionRepresenter
end

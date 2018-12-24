FactoryBot.define do
  factory(:payment_transaction) do
    success { true }
    amount { 100.to_has_money('EUR') }
    invoice { |invoice| invoice.association(:invoice) }
  end
end
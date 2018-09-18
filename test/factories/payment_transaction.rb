Factory.define(:payment_transaction) do |invoice|
  invoice.success true
  invoice.amount 100.to_has_money('EUR')
  invoice.invoice { |invoice| invoice.association(:invoice) }
end

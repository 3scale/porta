FactoryBot.define do
  factory(:invitation) do
    email "john@example.com"
    account {|a| a.association(:provider_account)}
  end
end

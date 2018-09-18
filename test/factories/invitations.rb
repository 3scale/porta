Factory.define(:invitation) do |f|
  f.email "john@example.com"
  f.account {|a| a.association(:provider_account)}
end

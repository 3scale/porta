Factory.define(:partner) do |f|
  f.sequence(:name){|n| "partner#{n}"}
  f.api_key "1234"
end

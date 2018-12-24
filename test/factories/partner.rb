FactoryBot.define do
  factory(:partner) do
    sequence(:name){|n| "partner#{n}"}
    api_key "1234"
  end
end

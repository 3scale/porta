FactoryBot.define do
  factory :access_token, class: ::AccessToken do
    association :owner, factory: :user
    scopes { ['stats'] }
    permission { 'rw' }
    sequence(:name)  { |n| "Alaska_#{n}" }
    sequence(:value) { |n| "wild_#{n}" }
  end
end

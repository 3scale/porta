FactoryBot.define do
  factory :access_token, class: ::AccessToken do
    association :owner, factory: :user
    scopes { ['stats'] }
    permission { 'rw' }
    sequence(:name) { |n| "Alaska_#{n}" }
    # value is generated automatically by after_initialize callback in model
  end
end

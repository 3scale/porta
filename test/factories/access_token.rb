Factory.define(:access_token, class: ::AccessToken) do |factory|
  factory.association :owner, factory: :user
  factory.scopes ['alaska']
  factory.permission 'rw'
  factory.sequence(:name)  { |n| "Alaska_#{n}" }
  factory.sequence(:value) { |n| "wild_#{n}" }
end

# frozen_string_literal: true

FactoryBot.define do
  factory :user_session do
    association :user, factory: :user_with_account
  end
end

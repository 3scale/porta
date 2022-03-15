# frozen_string_literal: true

FactoryBot.define do
  factory(:email_configuration, :class => EmailConfiguration) do
    association :account, factory: :provider_account

    sequence(:email) { |n| "source-email-#{n}@example.COM" }
    sequence(:user_name) { |n| "auth-email-username-#{n}" }
    sequence(:password) { |n| "auth-email-password-#{n}" }
  end
end

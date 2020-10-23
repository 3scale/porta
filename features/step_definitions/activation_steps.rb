# frozen_string_literal: true

When "I follow the activation link in an email sent to {string}" do |email|
  visit_in_email(%r{http://[^/]+/(p/)?activate/[a-z0-9]+}, email)
end

When "I follow the activation link in an email sent to {user}" do |user|
  step %(I follow the activation link in an email sent to "#{user.email}")
end

When "I visit a invalid activation link as a buyer" do
  visit activate_path(activation_code: 'wrongcode')
end

When "user {string} activates (him)(her)self" do |username|
  user = User.find_by!(username: username)

  if user.account.provider?
    visit provider_activate_path(activation_code: user.activation_code ||= '123')
  else
    visit activate_path(activation_code: user.activation_code)
  end
end

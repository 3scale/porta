# frozen_string_literal: true

Given "a contributor {string} of account {string}" do |user_name, account_name|
  step %(an user "#{user_name}" of account "#{account_name}")
  user = User.find_by!(username: user_name)
  user.role= :contributor
  user.activate!
end

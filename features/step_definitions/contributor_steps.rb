Given /^a contributor "([^\"]*)" of account "([^\"]*)"$/ do | user_name, account_name |
  step %(an user "#{user_name}" of account "#{account_name}")
  user = User.find_by_username! user_name
  user.role= :contributor
  user.activate!
end



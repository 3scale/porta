# frozen_string_literal: true

Given "I have enough email configs to fill many pages" do
  25.times do |i|
    FactoryBot.create(:email_configuration, account: master_account,
                                            email: "foo#{i}@example.com",
                                            user_name: "user_#{i}",
                                            password: "password#{i}")
  end
end

Then "I see my email configurations sorted alphabetically" do
  with_scope email_configurations_table do
    master_account.email_configurations.first(5).each do |ec|
      find('tbody td', text: ec.email)
    end
    pending # TODO: Implement and check sorting
  end
end

Then "I can filter them by user name" do

end

Then "I should not see all my email configurations" do
  total = master_account.email_configurations.size
  default_per_page = 20
  assert total > default_per_page

  assert_equal default_per_page, email_configurations_table.find_all('tbody tr').length
end

Then "I should be able to go to the next page" do
  find('.pf-c-button[data-action="next"]').click
end

Then "I should be able to filter them by email" do
  find('input[type="search"]')
  pending # TODO: implement and check filtering
end

Then "I should be able to create an email configuration" do
  pending # Fill form and click on create. Check new email config in index/DB.
end

def email_configurations_table
  find '.pf-c-table[aria-label="Email configurations table"]'
end

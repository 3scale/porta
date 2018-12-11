# frozen_string_literal: true

require 'test_helper'

class Tasks::UserTest < ActiveSupport::TestCase
  setup do
    providers = FactoryGirl.create_list(:simple_provider, 3, provider_account: master_account)
    providers.each do |provider|
      FactoryGirl.create(:member, account: provider)
      FactoryGirl.create(:admin, username: '3scaleadmin', account: provider)
      FactoryGirl.create_list(:admin, 2, account: provider)
    end
  end

  test 'update_all_first_admin_id' do
    execute_rake_task 'user.rake', 'user:update_all_first_admin_id'
    Account.providers.each { |account| assert_equal account.first_admin&.id, account.first_admin_id }
  end
end

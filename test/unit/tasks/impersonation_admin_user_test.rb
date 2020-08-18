# frozen_string_literal: true

require 'test_helper'

module Tasks
  class ImpersonationAdminUserTest < ActiveSupport::TestCase
    setup do
      @impersonation_other_admin_users = FactoryBot.build_list(:active_admin, 3, username: '3scaleadmin') do |user|
        user.account = FactoryBot.create(:simple_provider, provider_account: master_account)
        user.save!
      end

      @other_admin_users = FactoryBot.create_list(:active_admin, 2)
    end

    attr_reader :impersonation_other_admin_users, :other_admin_users

    test 'update' do
      other_admin_users_attributes_before = other_admin_users_attributes

      execute_rake_task 'impersonation_admin_user.rake', 'impersonation_admin_user:update', 'example-username', 'domain.example.com'

      # It doesn't test that ALL '3scaleadmin' users have been updated because this would be error-prone under concurrency
      impersonation_other_admin_users.each do |user|
        user.reload
        assert_equal 'example-username', user.username
        assert_equal "example-username+#{user.account.self_domain}@domain.example.com", user.email
      end

      # After upgrading to Rails v5.2, we can use `assert_no_changes` around `execute_rake_task` instead of this
      assert_equal other_admin_users_attributes_before, other_admin_users_attributes
    end

    protected

    def other_admin_users_attributes
      other_admin_users.map { |user| user.reload.attributes.slice('username', 'email') }
    end
  end
end

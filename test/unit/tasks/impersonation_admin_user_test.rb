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
      assert_no_changes "other_admin_users.map(&:reload)" do
        execute_rake_task 'impersonation_admin_user.rake', 'impersonation_admin_user:update', 'example-username', 'domain.example.com'
      end

      # It doesn't test that ALL '3scaleadmin' users have been updated because this would be error-prone under concurrency
      impersonation_other_admin_users.each do |user|
        user.reload
        assert_equal 'example-username', user.username
        assert_equal "example-username+#{user.account.internal_admin_domain}@domain.example.com", user.email
      end
    end
  end
end

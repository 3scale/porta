# frozen_string_literal: true

require 'test_helper'

class Tasks::ImpersonationAdminUserTest < ActiveSupport::TestCase
  setup do
    3.times do
      FactoryGirl.create(:active_admin,
                            username: '3scaleadmin',
                            account: FactoryGirl.create(:simple_provider)
                          )
    end
    FactoryGirl.create_list(:active_admin, 2)
  end

  test 'update' do
    execute_rake_task 'impersonation_admin_user.rake', 'impersonation_admin_user:update', 'example-username', 'domain.example.com'

    users = User.where(username: 'example-username')
    assert_equal 0, User.where(username: '3scaleadmin').count
    assert_equal 3, users.count
    assert_equal 2, User.where('username <> \'3scaleadmin\'').where('username <> \'example-username\'').count
    users.each { |user| assert_match /\Aexample\-username\+#{user.account.self_domain}@domain\.example\.com\z/, user.email }
  end
end

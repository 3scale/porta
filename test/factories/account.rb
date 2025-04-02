# frozen_string_literal: true

FactoryBot.define do
  factory(:account, parent: :account_without_users) do
    # after(:create) do |account|
    #   if account.users.empty?
    #     FactoryBot.create(:admin, username: account.org_name.gsub(/[^a-zA-Z0-9_.]+/, '_'),
    #                               account: account,
    #                               state: 'active')
    #   end
    # end

    after(:stub) do |account|
      admin = FactoryBot.build_stubbed(:admin)

      account.stubs(:admins).returns([admin])
      admin.stubs(:account).returns(account)
    end
  end

  factory(:buyer_account, parent: :account) do
    association :provider_account

    users { [association(:active_admin)] } # FIXME: move to :account but beware of failing tests
    buyer { true }

    approved
  end
end

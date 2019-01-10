require 'test_helper'

class AuditedHacksTest < ActiveSupport::TestCase
  disable_transactional_fixtures!

  def setup
    @provider = FactoryBot.create(:provider_account)
    Audited.audit_class.delete_all
  end

  def test_user
    User.current = @provider.provider_account.users.first!

    stub_core_change_provider_key(@provider.provider_key)

    Cinstance.with_auditing do
      assert_difference Audited.audit_class.method(:count) do
        Sidekiq::Testing.inline! do
          @provider.bought_cinstance.change_user_key!
        end
      end
    end

    audit = Audited.audit_class.last!
    assert_equal User.current, audit.user
  end

end

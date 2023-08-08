require 'test_helper'

class ApiDocs::ProviderDataTest < ActiveSupport::TestCase
  def setup
    @account = FactoryBot.create(:simple_provider)

    FactoryBot.create_list(:simple_user, 3, role: :admin, account: account)
    FactoryBot.create_list(:simple_user, 3, role: :member, account: account)
  end

  attr_accessor :account

  def test_provider_users_ids
    data = ApiDocs::ProviderData.new(account).as_json[:results]
    assert_equal 5, data[:provider_users_ids].size
  end

  def test_admin_ds
    data = ApiDocs::ProviderData.new(account).as_json[:results]
    assert_equal 3, data[:admin_ids].size
  end
end

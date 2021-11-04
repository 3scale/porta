require 'test_helper'

class AccessTokenTest < ActiveSupport::TestCase

  def setup
    @token = FactoryBot.build(:access_token, owner: nil)
  end

  def test_destroy_dependency
    @token.owner = member
    @token.save!

    member.destroy
    assert_raise(ActiveRecord::RecordNotFound) do
      @token.reload
    end
  end

  def test_non_public_scopes
    member.admin_sections = [:monitoring, :portal]
    member.save!
    @token.owner = member
    @token.save!

    Account.any_instance.expects(:provider_can_use?).with('cms_api').returns(false)
    assert_equal ['stats'], @token.available_scopes.values

    Account.any_instance.expects(:provider_can_use?).with('cms_api').returns(true)
    assert_equal ['cms', 'stats'], @token.available_scopes.values
  end

  def test_available_permissions
    assert_kind_of Hash, @token.available_permissions
  end

  def test_available_scopes
    @token.expects(:owner).returns(member).at_least_once
    assert_kind_of AccessToken::Scopes, @token.available_scopes
  end

  def test_available_scopes_user
    @token.expects(:owner).returns(member).at_least_once
    member.expects(:allowed_access_token_scopes).returns(AccessToken::Scopes.new([])).once

    @token.available_scopes
  end

  def test_scopes=
    @token.owner  = member
    @token.scopes = ['stats', 'cms', '', nil]
    @token.save!

    assert_equal ['stats', 'cms'], @token.scopes
  end

  def test_allowed_access_token_scopes
    member.admin_sections= [] and member.save!
    assert_equal [], member.allowed_access_token_scopes.values

    member.admin_sections= [:partners] and member.save!
    assert_equal ['account_management'], member.allowed_access_token_scopes.values

    member.admin_sections= %i[monitoring partners portal finance] and member.save!
    assert_same_elements %w[cms account_management stats finance], member.allowed_access_token_scopes.values
    ThreeScale.stubs(master_on_premises?: true)
    assert_same_elements %w[account_management stats], member.allowed_access_token_scopes.values
  end

  def test_validates_real_scopes
    @token.owner = member
    @token.scopes = %w[stats cms wrong]
    refute @token.valid?
    assert_equal ['invalid'], @token.errors[:scopes]

    @token.owner = member
    @token.scopes = %w[stats cms]
    assert @token.valid?

    ThreeScale.stubs(master_on_premises?: true)
    @token.owner = member
    @token.scopes = %w[stats cms]
    refute @token.valid?
    assert_equal ['invalid'], @token.errors[:scopes]

    @token.owner = member
    @token.scopes = %w[stats]
    assert @token.valid?
  end

  def test_human_scopes
    assert Array, @token.human_scopes
  end

  def test_scope_by_name
    %w[searchable another_name].each { |name| FactoryBot.create_list(:access_token, 2, name: name) }
    assert_same_elements AccessToken.where('name LIKE \'%arch%\'').pluck(:id), AccessToken.by_name('arch').pluck(:id)
    assert_same_elements AccessToken.all.pluck(:id), AccessToken.by_name('').pluck(:id)
  end

  def test_find_from_id_or_value_and_bang
    FactoryBot.create_list(:access_token, 2).each do |token|
      assert_equal token.id, AccessToken.find_from_id_or_value(token.id).id
      assert_equal token.id, AccessToken.find_from_id_or_value(token.value).id
      assert_equal token.id, AccessToken.find_from_id_or_value!(token.id).id
      assert_equal token.id, AccessToken.find_from_id_or_value!(token.value).id
    end
    assert_nil AccessToken.find_from_id_or_value('fake')
    assert_raise(ActiveRecord::RecordNotFound) { AccessToken.find_from_id_or_value!('fake') }
  end

  test 'timestamps filled' do
    access_token = FactoryBot.build(:access_token)
    expected_created_at = -1
    expected_updated_at = -1

    # Need to round it because database do not retain usec neither nsec
    Timecop.freeze(5.months.ago.round) do
      expected_created_at = Time.zone.now
      access_token.save!
    end

    # Need to round it because database do not retain usec neither nsec
    Timecop.freeze(5.hours.ago.round) do
      expected_updated_at = Time.zone.now
      access_token.update!(name: 'updated name')
    end

    assert_equal expected_created_at, access_token.created_at
    assert_equal expected_updated_at, access_token.updated_at
  end

  test 'creation is audited' do
    account = FactoryBot.create(:simple_provider)
    user = FactoryBot.create(:admin, account: account)
    access_token = FactoryBot.build(:access_token, owner: user)

    assert_difference(Audited.audit_class.method(:count)) do
      AccessToken.with_synchronous_auditing do
        access_token.save!
      end
    end

    audit = Audited.audit_class.last!
    assert_access_token_audit_all_data(access_token, audit)
    assert_equal 'create', audit.action
  end

  test 'deletion is audited' do
    account = FactoryBot.create(:simple_provider)
    user = FactoryBot.create(:admin, account: account)
    access_token = FactoryBot.create(:access_token, owner: user)

    assert_difference(Audited.audit_class.method(:count)) do
      AccessToken.with_synchronous_auditing do
        access_token.destroy!
      end
    end

    audit = Audited.audit_class.last!
    assert_access_token_audit_all_data(access_token, audit)
    assert_equal 'destroy', audit.action
  end

  test 'update is audited' do
    account = FactoryBot.create(:simple_provider)
    user = FactoryBot.create(:admin, account: account)
    access_token = FactoryBot.create(:access_token, owner: user, name: 'initial-name')

    initial_updated_at = access_token.updated_at

    Timecop.freeze(1.day.from_now.utc.round) do
      assert_difference(Audited.audit_class.method(:count)) do
        AccessToken.with_synchronous_auditing do
          access_token.update!(name: 'updated-name')
        end
      end
    end

    audit = Audited.audit_class.last!

    assert_equal 'update', audit.action
    assert_equal access_token.owner.account.provider_id_for_audits, audit.provider_id, "expected provider_id #{access_token.owner.account.provider_id_for_audits}, found #{audit.provider_id.inspect}"
    assert_equal access_token.class.name, audit.kind, "expected kind #{access_token.class.name}, but found #{audit.kind.inspect}"
    expected_audited_changes = {
      'name' => ['initial-name', 'updated-name'],
      'updated_at' => [initial_updated_at, access_token.updated_at]
    }
    assert_equal expected_audited_changes, audit.audited_changes
  end

  private

  def assert_access_token_audit_all_data(access_token, audit)
    assert_equal access_token.owner.account.provider_id_for_audits, audit.provider_id, "expected provider_id #{access_token.owner.account.provider_id_for_audits}, found #{audit.provider_id.inspect}"
    assert_equal access_token.class.name, audit.kind, "expected kind #{access_token.class.name}, but found #{audit.kind.inspect}"
    expected_audited_changes = {
      'owner_id' => access_token.owner.id,
      'scopes' => access_token.scopes,
      'name' => access_token.name,
      'permission' => access_token.permission,
      'created_at' => access_token.created_at.utc,
      'updated_at' => access_token.updated_at.utc
    }
    assert_equal expected_audited_changes, audit.audited_changes
  end

  def member
    @member ||= FactoryBot.build(:member, account: account)
  end

  def account
    @account ||= FactoryBot.build_stubbed(:simple_provider)
  end
end

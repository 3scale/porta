# frozen_string_literal: true

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  subject { @user || FactoryBot.create(:user) }

  should belong_to :account
  should allow_mass_assignment_of :username
  should allow_mass_assignment_of :email
  should allow_mass_assignment_of :first_name
  should allow_mass_assignment_of :last_name
  should allow_mass_assignment_of :password
  should allow_mass_assignment_of :password_confirmation
  should allow_mass_assignment_of :conditions
  should allow_mass_assignment_of :service_conditions
  should allow_mass_assignment_of :job_role

  setup do
    ActionMailer::Base.deliveries = []
  end

  test 'archive_as_deleted' do
    Features::SegmentDeletionConfig.stubs(enabled?: false) do
      user = FactoryBot.create(:simple_user)

      assert_no_difference(DeletedObject.users.method(:count)) { user.reload.destroy! }
    end

    Features::SegmentDeletionConfig.stubs(enabled?: true) do
      user = FactoryBot.create(:simple_user)

      assert_difference(DeletedObject.users.method(:count)) { user.reload.destroy! }

      assert_equal user.id, DeletedObject.users.last!.object_id
    end
  end

  def test_user_suspended_no_sessions
    user = FactoryBot.create(:simple_user)
    UserSession.create!(user: user)

    user.activate!
    assert user.user_sessions.present?
    assert user.can_login?

    user.suspend!
    user.reload
    assert_not user.user_sessions.present?
    assert_not user.can_login?
  end

  def test_find_with_valid_password_token
    user = FactoryBot.create(:simple_user)
    token = user.generate_lost_password_token
    assert_not_nil user.account.users.find_with_valid_password_token(token)

    user.expire_password_token
    assert_nil user.account.users.find_with_valid_password_token(token)
  end

  def test_nullify_authentication_id
    user = FactoryBot.create(:simple_user)
    user.expects(:any_sso_authorizations?).returns(true).at_least_once
    user.expects(:nullify_authentication_id).once
    assert user.save

    user.expects(:any_sso_authorizations?).returns(false).at_least_once
    user.expects(:nullify_authentication_id).never
    assert user.save
  end

  class DoubleSsoAuthorizations; end

  def test_any_sso_authorizations?
    sso_authorizations = DoubleSsoAuthorizations.new
    user = FactoryBot.build_stubbed(:simple_user)
    user.stubs(:sso_authorizations).returns(sso_authorizations)

    user.expects(:persisted?).returns(true).once
    sso_authorizations.expects(:exists?).returns(true).once
    assert user.any_sso_authorizations?

    user.expects(:persisted?).returns(false).once
    sso_authorizations.expects(:any?).returns(true).once
    assert user.any_sso_authorizations?
  end

  def test_accessible_service_tokens
    provider = FactoryBot.create(:simple_provider)
    service = FactoryBot.create(:service, account: provider)
    member = FactoryBot.build_stubbed(:member, account: provider)

    service.service_tokens.create!(value: 'money-makes-people-cautious')

    assert_equal 0, member.accessible_service_tokens.count

    member.member_permission_ids = ['plans']
    assert_equal 1, member.accessible_service_tokens.count
  end

  def test_accessible_services
    provider = FactoryBot.create(:simple_provider)
    service = FactoryBot.create(:service, account: provider)
    another_service = FactoryBot.create(:service, account: provider)
    admin = FactoryBot.build_stubbed(:admin, account: provider)
    member = FactoryBot.build_stubbed(:member, account: provider)

    assert_same_elements [service.id, another_service.id], admin.accessible_services.map(&:id)
    assert_equal [], member.accessible_services.map(&:id)

    member.member_permission_ids = ['partners']

    assert_same_elements [service.id, another_service.id], member.accessible_services.map(&:id)

    member.member_permission_service_ids = [service.id]

    assert_equal [service.id], member.accessible_services.map(&:id)

    member.member_permission_service_ids = []

    assert_equal [], member.accessible_services.map(&:id)
  end

  test '#find_by_username_or_email returns nil for TypeError' do
    assert_nil User.find_by_username_or_email({ "＄foo" => "bar1" }) # rubocop:disable Rails/DynamicFindBy
  end

  test '#multiple_accessible_services?' do
    provider = FactoryBot.create(:simple_provider)
    user = FactoryBot.create(:user, account: provider)
    FactoryBot.create_list(:simple_service, 2, account: provider)

    Service.stubs(permitted_for: [provider.services.last!.id])
    assert_not user.multiple_accessible_services?

    Service.stubs(permitted_for: Service.all)
    assert user.multiple_accessible_services?

    provider.services.first!.mark_as_deleted!
    assert_not user.multiple_accessible_services?
  end

  test 'validate emails of providers users' do
    provider = FactoryBot.create(:simple_provider)
    other_provider = FactoryBot.create(:simple_provider)

    provider_user = FactoryBot.create(:simple_user, account: provider)
    other_provider_user = FactoryBot.create(:simple_user, account: other_provider)

    buyer = FactoryBot.create(:simple_buyer, provider_account: provider)
    other_buyer = FactoryBot.create(:buyer_account, provider_account: other_provider)

    user = FactoryBot.create(:simple_user, account: buyer)
    other_user = FactoryBot.create(:simple_user, account: buyer)
    other_buyer_user = FactoryBot.create(:simple_user, account: other_buyer)

    assert user.unique?(:email)
    assert other_user.unique?(:email)
    assert other_provider_user.unique?(:email)

    other_provider_user.update(email: user.email)
    assert other_provider_user.unique?(:email)

    other_user.update(email: user.email)
    assert_not other_user.unique?(:email)

    other_provider_user.update(email: user.email)
    assert other_provider_user.unique?(:email)

    other_provider_user.update(email: provider_user.email)
    assert other_provider_user.unique?(:email)

    provider.update(self_domain: 'some.example.com')
    assert other_provider_user.unique?(:email)

    other_user.update(email: other_buyer_user.email)
    assert other_user.unique?(:email)
  end

  test 'signup.oauth2?' do
    user = FactoryBot.build(:user)

    user.authentication_id = 'foobar'
    assert user.signup.oauth2?

    user.authentication_id = nil
    assert_not user.signup.oauth2?

    user.expects(:sso_authorizations).returns([]).once
    assert_not user.signup.oauth2?

    user.expects(:sso_authorizations).returns([SSOAuthorization.new]).once
    assert user.signup.oauth2?
  end

  test 'should validate uniqueness of username and email' do
    provider = FactoryBot.create(:simple_provider)

    user = FactoryBot.create(:simple_user, account: provider)
    other_user = FactoryBot.create(:simple_user, account: provider)

    assert user.valid?
    assert other_user.valid?

    other_user.attributes = {
      email: user.email,
      username: user.username
    }
    assert_not other_user.valid?

    assert_not other_user.errors[:email].blank?
    assert_not other_user.errors[:username].blank?
  end

  test 'destroyed user should have to_xml working' do
    user = FactoryBot.create(:simple_user)
    user.destroy
    assert user.to_xml
  end

  test 'New User allow emails with dot before @' do
    @user = User.new(username: 'foo', password: 'monkey')
    assert validate_acceptance_of :conditions
    assert allow_value('foo.bar@monkey.ao').for(:email)
    assert allow_value('foo+bar@monkey.ao').for(:username)
  end

  test 'minimal signup should not validate anything except username' do
    user = User.new
    user.signup_type = :minimal
    user.username = 'liz'

    user.valid?
    assert user.valid?
  end

  test 'minimal signup should not be created in active state if it has no password' do
    user = User.new
    user.signup_type = :minimal
    user.username = 'liz'
    user.save!

    assert_not_equal "active", user.state
  end

  test 'minimal signup should not send notifications when created' do
    user = User.new
    user.signup_type = :minimal
    UserMailer.expects(:deliver_signup_notification).never
    UserMailer.expects(:deliver_activation_notification).never

    user.username = 'liz'
    user.password = 'superSecret1234#'
    user.save!
  end

  test 'api signup should not validate password' do
    api_user = User.new
    api_user.signup_type = :api

    api_user.valid?
    assert api_user.errors[:password].blank?
  end

  test 'created_by_provider signup should not validate password' do
    created_by_provider_user = User.new
    created_by_provider_user.signup_type = :created_by_provider

    created_by_provider_user.valid?
    assert created_by_provider_user.errors[:password].blank?
  end

  test 'reset password' do
    user = FactoryBot.create(:simple_user, username: 'person', password: 'superSecret1234#')
    user.activate!

    user.update(password: 'new_password_123', password_confirmation: 'new_password_123')

    assert user.authenticated?('new_password_123')
  end

  class ExistingProviderUserTest < ActiveSupport::TestCase
    include ActiveJob::TestHelper

    setup do
      ActionMailer::Base.deliveries = []
      # This is needed, database will not save fractions of seconds
      # so something like:
      # Time.now.to_f #=> 1512012308.293877
      # will be saved in DB as 1512012308
      travel_to(Time.zone.parse('2017-11-23 03:25:08 UTC +00:00'))

      provider_account = FactoryBot.create(:simple_provider)

      account = FactoryBot.create(:simple_account, provider_account: provider_account, state: 'approved')

      @user = FactoryBot.create(:simple_user, account: account,
                                              username: 'person',
                                              email: 'person@example.org',
                                              password: 'superSecret1234#')
      @user.activate!
    end

    test 'not rehash password' do
      @user.update(username: 'person2')
      @user.reload

      assert @user.authenticated?('superSecret1234#')
    end

    test 'set remember_token' do
      @user.remember_me
      assert_not_nil @user.remember_token
      assert_not_nil @user.remember_token_expires_at
    end

    test 'unset remember_token' do
      @user.remember_me
      assert_not_nil @user.remember_token
      @user.forget_me
      assert_nil @user.remember_token
    end

    test 'remember_me default two weeks' do
      before = 2.weeks.from_now
      @user.remember_me
      after = 2.weeks.from_now
      assert_not_nil @user.remember_token
      assert_not_nil @user.remember_token_expires_at
      assert @user.remember_token_expires_at.between?(before, after)
    end

    test 'remember_me_until one week' do
      time = 1.week.from_now
      @user.remember_me_until time
      assert_not_nil @user.remember_token
      assert_not_nil @user.remember_token_expires_at
      assert_equal @user.remember_token_expires_at, time
    end

    test 'remember_me_for one week' do
      before = 1.week.from_now
      @user.remember_me_for 1.week
      after = 1.week.from_now
      assert_not_nil @user.remember_token
      assert_not_nil @user.remember_token_expires_at
      assert @user.remember_token_expires_at.between?(before, after)
    end

    test 'not require acceptance of conditions' do
      assert_accepts allow_value(nil).for(:conditions), @user
      assert_accepts allow_value(false).for(:conditions), @user
      assert_accepts allow_value('0').for(:conditions), @user
    end

    test 'should have db column' do
      assert have_db_column :lost_password_token
    end

    test 'respond to :generate_lost_password_token!' do
      assert @user.respond_to? :generate_lost_password_token!
    end

    test 'generate lost password token on :generate_lost_password_token!' do
      @user.lost_password_token = nil

      @user.generate_lost_password_token!

      assert_not_nil @user.lost_password_token
      assert_not_nil @user.lost_password_token_generated_at
    end

    test 'send lost password email on :generate_lost_password_token!' do
      @user.account.update_column(:provider, true) # rubocop:disable Rails/SkipsModelValidations

      perform_enqueued_jobs(only: ActionMailer::MailDeliveryJob) do
        @user.generate_lost_password_token!
      end
      message = ActionMailer::Base.deliveries.last

      assert_not_nil message
      assert_equal 'Password Recovery', message.subject
      assert_equal [@user.email], message.to
    end

    test 'send buyer lost password email on :generate_lost_password_token!' do
      @user.account.update_column(:provider, false) # rubocop:disable Rails/SkipsModelValidations

      perform_enqueued_jobs(only: ActionMailer::MailDeliveryJob) do
        @user.generate_lost_password_token!
      end

      message = ActionMailer::Base.deliveries.last

      assert_not_nil message
      assert_match 'Lost password recovery. (Valid for 24 hours)', message.subject
      assert_equal [@user.email], message.to
    end

    test 'with lost_password_token should reset lost_password_token when password is changed' do
      @user.generate_lost_password_token!
      @user = User.find(@user.id) # HACK: to reset stored passwords
      @user.update_password('new_password_123', 'new_password_123')
      @user.save!

      assert_nil @user.lost_password_token
    end

    test 'with lost_password_token should not reset lost_password_token when user is updated without password change' do
      @user.generate_lost_password_token!
      @user = User.find(@user.id) # HACK: to reset stored passwords
      @user.username = 'bob'
      @user.save!

      assert_not_nil @user.lost_password_token
    end

    test 'with lost_password_token should not reset lost_password_token when user incorrectly confirms new password' do
      @user.generate_lost_password_token!
      @user = User.find(@user.id) # HACK: to reset stored passwords
      @user.update_password('new_password_123', 'not_new_password_123')
      assert_not_nil @user.lost_password_token
    end
  end

  test 'two users of two buyer accounts of the same provider accounts need unique email' do
    provider_account = FactoryBot.create(:simple_provider)
    buyer_account_one = FactoryBot.create(:simple_buyer, provider_account: provider_account)
    buyer_account_two = FactoryBot.create(:simple_buyer, provider_account: provider_account)
    FactoryBot.create(:simple_user, account: buyer_account_one, email: 'foo@example.org')

    user_two = FactoryBot.build(:simple_user, account: buyer_account_two, email: 'foo@example.org')
    assert_not user_two.valid?
    assert_not user_two.errors[:email].blank?
  end

  test 'two users of two buyer accounts of two different provider accounts can have the same email' do
    provider_account_one = FactoryBot.create(:simple_provider)
    provider_account_two = FactoryBot.create(:simple_provider)
    buyer_account_one = FactoryBot.create(:simple_buyer, provider_account: provider_account_one)
    buyer_account_two = FactoryBot.create(:simple_buyer, provider_account: provider_account_two)
    FactoryBot.create(:simple_user, account: buyer_account_one, email: 'foo@example.org')

    user_two = FactoryBot.build(:simple_user, account: buyer_account_two, email: 'foo@example.org')
    assert user_two.valid?
  end

  # currently provider has to have self domain
  pending_test 'two users of two provider accounts need unique emails when provider has no self domain' do
    account_one = FactoryBot.create(:provider_account, :self_domain => nil)
    account_two = FactoryBot.create(:provider_account, :self_domain => nil)
    FactoryBot.create(:user, account: account_one, email: 'foo@example.org')

    user_two = FactoryBot.build(:user, account: account_two, email: 'foo@example.org')
    assert_not user_two.valid?
    assert_not_nil user_two.errors[:email].presence
  end

  test 'users of buyer accounts of a provider can use same email address and/or username than users of the provider' do
    provider_account = FactoryBot.create(:simple_provider)
    buyer_account = FactoryBot.create(:simple_buyer, provider_account: provider_account)

    provider_user = FactoryBot.create(:simple_user, account: provider_account, email: 'foo@example.org', username: 'unique_username')

    buyer_user = FactoryBot.build(:simple_user, account: buyer_account, email: provider_user.email)
    assert buyer_user.valid?

    buyer_user = FactoryBot.build(:simple_user, account: buyer_account, username: buyer_user.username)
    assert buyer_user.valid?
  end

  test 'users of a provider can use same email address and/or username than users of buyer accounts of the provider' do
    provider_account = FactoryBot.create(:simple_provider)
    buyer_account = FactoryBot.create(:simple_buyer, provider_account: provider_account)

    buyer_user = FactoryBot.create(:simple_user, account: buyer_account, email: 'foo@example.org', username: 'unique_username')

    provider_user = FactoryBot.build(:simple_user, account: provider_account, email: buyer_user.email)
    assert provider_user.valid?

    provider_user = FactoryBot.build(:simple_user, account: provider_account, username: buyer_user.username)
    assert provider_user.valid?
  end

  #   test 'does not set session token when created' do
  #     user = FactoryBot.create(:user)
  #     assert_nil user.session_token
  #     assert_nil user.session_token_expires_at
  #   end
  #
  #   test 'generates session_token' do
  #     user = FactoryBot.create(:user)
  #
  #     travel_to(2009, 11, 22, 14, 30, 12) do
  #       user.generate_session_token!
  #
  #       assert_not_nil user.session_token
  #       assert_equal Time.zone.now + 30.seconds, user.session_token_expires_at
  #     end
  #   end
  #
  #   test 'User.authenticate_by_session_token returns user with the given token' do
  #     user = FactoryBot.create(:user)
  #     user.generate_session_token!
  #
  #     found_user = User.authenticate_by_session_token(user.session_token)
  #
  #     assert_equal user, found_user
  #     assert_nil found_user.session_token
  #     assert_nil found_user.session_token_expires_at
  #   end
  #
  #   test 'User.authenticate_by_session_token returns nil if no user has the given token' do
  #     assert_nil User.authenticate_by_session_token('1234')
  #   end
  #
  #   test 'User.authenticate_by_session_token returns nil if token is expired' do
  #     user = FactoryBot.create(:user)
  #     user.generate_session_token!
  #
  #     travel_to(1.minute.from_now) do
  #       assert_nil User.authenticate_by_session_token(user.session_token)
  #     end
  #   end
  #
  #   test 'User#url_with_session_token appends session token to the given url' do
  #     user = FactoryBot.create(:user)
  #     user.generate_session_token!
  #
  #     assert_equal "http://example.net?session_token=#{user.session_token}",
  #     user.url_with_session_token('http://example.net')
  #
  #     assert_equal "http://example.net?name=value&session_token=#{user.session_token}",
  #     user.url_with_session_token('http://example.net?name=value')
  #   end

  test '#update_last_login! updates last_login_at and last_login_ip' do
    user = FactoryBot.create(:simple_user)
    user.update_last_login!(time: Time.utc(2010, 6, 30, 12, 36), ip: '2.3.4.5')

    assert_equal Time.utc(2010, 6, 30, 12, 36), user.last_login_at
    assert_equal '2.3.4.5', user.last_login_ip
  end

  test '#can_login? returns false if user is not active' do
    user = FactoryBot.create(:pending_user)
    assert_not user.can_login?
  end

  test 'admin sections' do
    user = FactoryBot.create(:simple_user)
    assert user.valid?

    user.admin_sections = ['monitoring']

    assert_equal Set[:monitoring], user.admin_sections
    assert user.valid?
  end

  test '#can_login? returns false if user is suspended' do
    user = FactoryBot.create(:simple_user)
    user.activate!
    user.suspend!

    assert_not user.can_login?
  end

  test '#can_login? returns false if the account is pending' do
    account = FactoryBot.create(:account_without_users)
    user = FactoryBot.create(:user, account: account)

    user.activate!
    account.make_pending!

    assert_not user.can_login?
  end

  test '#can_login? returns false if the account is rejected' do
    account = FactoryBot.create(:account_without_users)
    user = FactoryBot.create(:user, account: account)

    user.activate!
    account.reject!

    assert_not user.can_login?
  end

  test '#can_login? returns true if the user is active and the account is approved' do
    account = FactoryBot.create(:account_without_users)
    user = FactoryBot.create(:user, account: account)

    user.activate!

    assert user.can_login?
  end

  class DeletionOfUsersTest < ActiveSupport::TestCase
    setup do
      @account = FactoryBot.create(:account, org_name: "Alice's web empire")
    end

    class RoleMemberTest < self
      setup do
        @not_admin = FactoryBot.create(:simple_user, account: @account, role: :member)
      end

      test 'should be allowed' do
        assert_raise ActiveRecord::RecordNotFound do
          @not_admin.destroy.reload
        end
      end

      test 'should return true on call to can_be_destroyed?' do
        assert @not_admin.can_be_destroyed?
      end
    end

    class RoleAdminTest < self
      setup do
        @admin = @account.admins.first
      end

      class NotBeingTheUniqueAdminTest < self
        setup do
          @admin = FactoryBot.create(:user, account: @account, role: :admin)
        end

        test 'should be allowed' do
          assert @account.admins.length > 1

          assert_raise ActiveRecord::RecordNotFound do
            @admin.destroy.reload
          end
        end

        test 'should return true on call to can_be_destroyed?' do
          assert @account.admins.length > 1

          assert @admin.can_be_destroyed?
        end
      end

      class BeingTheUniqueAdminTest < self
        test 'should not be allowed' do
          assert_equal 1, @account.admins.length

          @account.admins.first.destroy

          assert_equal 1, @account.admins.length
        end

        test 'should return true on call to can_be_destroyed?' do
          assert_equal 1, @account.admins.length

          assert_not @account.admins.first.can_be_destroyed?
        end
      end
    end
  end

  class WebhookTest < ActiveSupport::TestCase
    include WebHookTestHelpers

    setup do
      @buyer = FactoryBot.create(:buyer_account)
      @provider = @buyer.provider_account
      @user = @provider.admins.first
    end

    test 'should be pushed if the user is created by user' do
      new_user = FactoryBot.build(:simple_user, account: @buyer)
      User.current = @user

      fires_webhook(new_user)

      new_user.save!
    end

    test 'should not be pushed if the user is not created by user' do
      new_user = FactoryBot.build(:simple_user, account: @buyer)
      User.current = nil

      fires_webhook.never
      new_user.save!
    end

    test 'should be pushed if the user is updated by user' do
      updated_user = FactoryBot.create(:simple_user, account: @buyer)
      User.current = @user

      fires_webhook(updated_user)

      updated_user.username += " "
      updated_user.save!
    end

    test 'should not be pushed if the user is not updated by user' do
      updated_user = FactoryBot.create(:simple_user, account: @buyer)
      User.current = nil

      fires_webhook.never

      updated_user.username += " "
      updated_user.save!
    end

    test 'should be pushed asynchronously if the user is destroyed by user' do
      destroyed_user = FactoryBot.create(:simple_user, account: @buyer)
      User.current = @user

      fires_webhook(destroyed_user, 'deleted')

      destroyed_user.destroy
    end

    test 'should not be pushed if the user is not destroyed by user' do
      destroyed_user = FactoryBot.create(:simple_user, account: @buyer)
      User.current = nil

      fires_webhook.never

      destroyed_user.destroy
    end
  end

  test 'fields and extra fields should be' do
    assert FieldsDefinition.targets.include?("User")
  end

  test '.model_name.human is User' do
    assert_equal 'User', User.model_name.human
  end

  test '#sections users with no sections should be empty' do
    @buyer = FactoryBot.create(:buyer_account)
    @user = @buyer.users.first
    assert @user.sections.empty?
  end

  test '#sections users with sections should contain account sections' do
    @buyer = FactoryBot.create(:buyer_account)
    @user = @buyer.users.first
    @section = FactoryBot.create(:cms_section, public: false, title: "protected-section",
                                 parent: @buyer.provider_account.sections.root, provider: @buyer.provider_account)

    grant_buyer_access_to_section @buyer, @section
    assert_equal @user.sections, [@section]
  end

  test 'destroys its invitation' do
    invitation = FactoryBot.create(:invitation, email: "invited@example.com", account: FactoryBot.create(:provider_account))
    user = invitation.make_user username: "username", password: "superSecret1234#"
    user.save!

    user.destroy
    assert_raise ActiveRecord::RecordNotFound do
      invitation.reload
    end
  end

  test "won't destroy user if invitation can't be destroyed" do
    Invitation.any_instance.stubs(:destroy).returns(false)

    invitation = FactoryBot.create(:invitation)
    user = invitation.make_user username: "username", password: "superSecret1234#"
    user.save!

    assert_not user.destroy
    assert Invitation.exists?(invitation[:id])
  end

  test "kill user sessions but current one" do
    user = FactoryBot.create :user
    session1 = user.user_sessions.create
    user.user_sessions.create

    user.kill_user_sessions(session1)

    assert_equal session1, user.user_sessions.reload.first
    assert_equal 1, user.user_sessions.reload.length
  end

  test 'new provider users have notification preferences' do
    provider = FactoryBot.create :simple_provider
    user = FactoryBot.build :user, account: provider

    user.save

    assert user.notification_preferences.persisted?
  end

  test "new buyer users don't have notification preferences" do
    buyer = FactoryBot.create :simple_buyer
    user = FactoryBot.build :user, account: buyer

    user.save

    assert_not user.notification_preferences.persisted?
  end
end

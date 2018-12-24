require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class UserTest < ActiveSupport::TestCase
  disable_transactional_fixtures!

  subject { @user || Factory(:user) }

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

  def test_user_suspended_no_sessions
    user = FactoryBot.create(:simple_user)
    UserSession.create!(user: user)

    user.activate!
    assert user.user_sessions.present?
    assert user.can_login?
    
    user.suspend!
    user.reload
    refute user.user_sessions.present?
    refute user.can_login?
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
    service  = FactoryBot.create(:service, account: provider)
    member   = FactoryBot.build_stubbed(:member, account: provider)

    service.service_tokens.create!(value: 'money-makes-people-cautious')

    member.stubs(:has_access_to_all_services?).returns(true)
    member.expects(:has_permission?).with(:plans).returns(true)
    assert_equal 1, member.accessible_service_tokens.count

    member.expects(:has_permission?).with(:plans).returns(false)
    assert_equal 0, member.accessible_service_tokens.count
  end

  def test_accessible_services
    provider = FactoryBot.create(:simple_provider)
    service  = FactoryBot.create(:service, account: provider)
    admin    = FactoryBot.build_stubbed(:admin, account: provider)
    member   = FactoryBot.build_stubbed(:member, account: provider)

    assert_equal 1, admin.accessible_services.count
    assert_equal 1, member.accessible_services.count

    member.stubs(:has_access_to_all_services?).returns(true)

    assert_equal 1, member.accessible_services.count

    member.stubs(:has_access_to_all_services?).returns(false)
    member.stubs(:member_permission_service_ids).returns([service.id])

    assert_equal 1, member.accessible_services.count

    member.stubs(:member_permission_service_ids).returns([])

    assert_equal 0, member.accessible_services.count
  end

  test '#multiple_accessible_services?' do
    provider = FactoryBot.create(:simple_provider)
    user = FactoryBot.create(:user, account: provider)
    FactoryBot.create_list(:simple_service, 2, account: provider)

    Service.stubs(permitted_for_user: [provider.services.last!.id])
    refute user.multiple_accessible_services?

    Service.stubs(permitted_for_user: Service.all)
    assert user.multiple_accessible_services?

    provider.services.first!.mark_as_deleted!
    refute user.multiple_accessible_services?
  end

  test 'validate emails of providers users' do
    provider = Factory(:simple_provider)
    other_provider = Factory(:simple_provider)

    provider_user = Factory(:simple_user, :account => provider)
    other_provider_user = Factory(:simple_user, :account => other_provider)

    buyer = Factory(:simple_buyer, :provider_account => provider)
    other_buyer = Factory(:buyer_account, :provider_account => other_provider)

    user = Factory(:simple_user, :account => buyer)
    other_user = Factory(:simple_user, :account => buyer)
    other_buyer_user = Factory(:simple_user, :account => other_buyer)

    assert user.unique?(:email)
    assert other_user.unique?(:email)
    assert other_provider_user.unique?(:email)

    other_provider_user.update_attribute :email, user.email
    assert other_provider_user.unique?(:email)

    other_user.update_attribute :email, user.email
    assert !other_user.unique?(:email)

    other_provider_user.update_attribute :email, user.email
    assert other_provider_user.unique?(:email)

    other_provider_user.update_attribute :email, provider_user.email
    assert other_provider_user.unique?(:email)

    provider.update_attribute :self_domain, 'some.example.com'
    assert other_provider_user.unique?(:email)

    other_user.update_attribute :email, other_buyer_user.email
    assert other_user.unique?(:email)
  end

  test 'signup.oauth2?' do
    user = Factory.build(:user)

    user.authentication_id = 'foobar'
    assert user.signup.oauth2?

    user.authentication_id = nil
    refute user.signup.oauth2?

    user.expects(:sso_authorizations).returns([]).once
    refute user.signup.oauth2?

    user.expects(:sso_authorizations).returns([SSOAuthorization.new]).once
    assert user.signup.oauth2?
  end

  test 'should validate uniqueness of username and email' do
    provider = Factory(:simple_provider)

    user = Factory(:simple_user, :account => provider)
    other_user = Factory(:simple_user, :account => provider)

    assert user.valid?
    assert other_user.valid?

    other_user.attributes = {
      :email => user.email,
      :username => user.username
    }
    assert !other_user.valid?

    assert !other_user.errors[:email].blank?
    assert !other_user.errors[:username].blank?
  end

  context 'destroyed user' do
    setup do
      @user = Factory(:simple_user)
      @user.destroy
    end

    should 'have to_xml working' do
      assert @user.to_xml
    end
  end

  context 'New User' do
    setup do
      @user = User.new(:username => 'foo', :password => 'monkey')
    end

    should validate_acceptance_of :conditions

    # Allow emails with dot before @
    should allow_value('foo.bar@monkey.ao').for(:email)

    should allow_value('foo+bar@monkey.ao').for(:username)
  end

  context 'minimal signup' do
    setup do
      @user = User.new
      @user.signup_type = :minimal
    end

    should 'not validate anything except username' do
      @user.username = 'liz'

      @user.valid?
      assert @user.valid?
    end

    should 'not be created in active state if it has no password' do
      @user.username = 'liz'
      @user.save!

      assert_not_equal "active", @user.state
    end

    should 'not send notifications when created' do
      UserMailer.expects(:deliver_signup_notification).never
      UserMailer.expects(:deliver_activation_notification).never

      @user.username = 'liz'
      @user.password = 'foobar'
      @user.save!
    end

  end # minimal signup

  context 'api signup' do

    should 'not validate password' do
      api_user = User.new
      api_user.signup_type = :api

      api_user.valid?
      assert api_user.errors[:password].blank?
    end

  end # api signup

  context 'created_by_provider signup' do

    should 'not validate password' do
      created_by_provider_user = User.new
      created_by_provider_user.signup_type = :created_by_provider

      created_by_provider_user.valid?
      assert created_by_provider_user.errors[:password].blank?
    end

  end # created_by_provider signup

  test 'reset password' do
    user = Factory(:simple_user, :username => 'person', :password => 'foobar')
    user.activate!

    user.update_attributes(:password => 'new password',
                           :password_confirmation => 'new password')

    assert user.authenticated?('new password')
  end

  # TODO: get rid of this context
  context 'Existing Provider user' do
    setup do
      provider_account = Factory(:simple_provider)

      account = Factory(:simple_account, :provider_account => provider_account, state: 'approved')

      @user = Factory(:simple_user, :account  => account,
                      :username => 'person',
                      :email    => 'person@example.org',
                      :password => 'redpanda')
      @user.activate!
    end

    should 'not rehash password' do
      @user.update_attributes(:username => 'person2')
      @user.reload

      assert @user.authenticated?('redpanda')
    end

    should 'set remember_token' do
      @user.remember_me
      assert_not_nil @user.remember_token
      assert_not_nil @user.remember_token_expires_at
    end

    should 'unset remember_token' do
      @user.remember_me
      assert_not_nil @user.remember_token
      @user.forget_me
      assert_nil @user.remember_token
    end

    should 'remember_me default two weeks' do
      before = 2.weeks.from_now.utc
      @user.remember_me
      after = 2.weeks.from_now.utc
      assert_not_nil @user.remember_token
      assert_not_nil @user.remember_token_expires_at
      assert @user.remember_token_expires_at.between?(before, after)
    end

    should 'remember_me_until one week' do
      time = 1.week.from_now.utc
      @user.remember_me_until time
      assert_not_nil @user.remember_token
      assert_not_nil @user.remember_token_expires_at
      assert_equal @user.remember_token_expires_at, time
    end

    should 'remember_me_for one week' do
      before = 1.week.from_now.utc
      @user.remember_me_for 1.week
      after = 1.week.from_now.utc
      assert_not_nil @user.remember_token
      assert_not_nil @user.remember_token_expires_at
      assert @user.remember_token_expires_at.between?(before, after)
    end

    should 'not require acceptance of conditions' do
      assert_accepts allow_value(nil).for(:conditions), @user
      assert_accepts allow_value(false).for(:conditions), @user
      assert_accepts allow_value('0').for(:conditions), @user
    end

    should have_db_column :lost_password_token

    should 'respond to :generate_lost_password_token!' do
      assert @user.respond_to? :generate_lost_password_token!
    end

    should 'generate lost password token on :generate_lost_password_token!' do
      @user.lost_password_token = nil

      @user.generate_lost_password_token!
      assert_not_nil @user.lost_password_token
      assert_not_nil @user.lost_password_token_generated_at
    end

    should 'send lost password email on :generate_lost_password_token!' do
      @user.account.provider = true
      @user.generate_lost_password_token!

      message = ActionMailer::Base.deliveries.last

      assert_not_nil message
      assert_equal 'Password Recovery',  message.subject
      assert_equal [@user.email], message.to
    end

    should 'send buyer lost password email on :generate_lost_password_token!' do
      @user.account.provider = false
      @user.generate_lost_password_token!

      message = ActionMailer::Base.deliveries.last

      assert_not_nil message
      assert_match 'Lost password recovery. (Valid for 24 hours)', message.subject
      assert_equal [@user.email], message.to
    end

    context 'with lost_password_token' do
      setup do
        @user.generate_lost_password_token!
        @user = User.find(@user.id) # HACK: to reset stored passwords
      end

      should 'reset lost_password_token when password is changed' do
        @user.update_password('new_password', 'new_password')
        @user.save!

        assert_nil @user.lost_password_token
      end

      should 'not reset lost_password_token when user is updated without password change' do
        @user.username = 'bob'
        @user.save!

        assert_not_nil @user.lost_password_token
      end

      should 'not reset lost_password_token when user incorrectly confirms new password' do
        @user.update_password('new_password', 'not_new_password')
        assert_not_nil @user.lost_password_token
      end
    end
  end

  test 'two users of two buyer accounts of the same provider accounts need unique email' do
    provider_account = Factory(:simple_provider)
    buyer_account_one = Factory(:simple_buyer, :provider_account => provider_account)
    buyer_account_two = Factory(:simple_buyer, :provider_account => provider_account)
    Factory(:simple_user, :account => buyer_account_one, :email => 'foo@example.org')

    user_two = Factory.build(:simple_user, :account => buyer_account_two, :email => 'foo@example.org')
    assert !user_two.valid?
    assert !user_two.errors[:email].blank?
  end

  test 'two users of two buyer accounts of two different provider accounts can have the same email' do
    provider_account_one = Factory(:simple_provider)
    provider_account_two = Factory(:simple_provider)
    buyer_account_one = Factory(:simple_buyer, :provider_account => provider_account_one)
    buyer_account_two = Factory(:simple_buyer, :provider_account => provider_account_two)
    Factory(:simple_user, :account => buyer_account_one, :email => 'foo@example.org')

    user_two = Factory.build(:simple_user, :account => buyer_account_two, :email => 'foo@example.org')
    assert user_two.valid?
  end

  # currently provider has to have self domain
  pending_test 'two users of two provider accounts need unique emails when provider has no self domain' do
    account_one = Factory(:provider_account, :self_domain => nil)
    account_two = Factory(:provider_account, :self_domain => nil)
    Factory(:user, :account => account_one, :email => 'foo@example.org')

    user_two = Factory.build(:user, :account => account_two, :email => 'foo@example.org')
    assert !user_two.valid?
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
  #     user = Factory(:user)
  #     assert_nil user.session_token
  #     assert_nil user.session_token_expires_at
  #   end
  #
  #   test 'generates session_token' do
  #     user = Factory(:user)
  #
  #     Timecop.freeze(2009, 11, 22, 14, 30, 12) do
  #       user.generate_session_token!
  #
  #       assert_not_nil user.session_token
  #       assert_equal Time.zone.now + 30.seconds, user.session_token_expires_at
  #     end
  #   end
  #
  #   test 'User.authenticate_by_session_token returns user with the given token' do
  #     user = Factory(:user)
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
  #     user = Factory(:user)
  #     user.generate_session_token!
  #
  #     Timecop.travel(1.minute.from_now) do
  #       assert_nil User.authenticate_by_session_token(user.session_token)
  #     end
  #   end
  #
  #   test 'User#url_with_session_token appends session token to the given url' do
  #     user = Factory(:user)
  #     user.generate_session_token!
  #
  #     assert_equal "http://example.net?session_token=#{user.session_token}",
  #     user.url_with_session_token('http://example.net')
  #
  #     assert_equal "http://example.net?name=value&session_token=#{user.session_token}",
  #     user.url_with_session_token('http://example.net?name=value')
  #   end

  test '#update_last_login! updates last_login_at and last_login_ip' do
    user = Factory(:simple_user)
    user.update_last_login!(:time => Time.utc(2010, 6, 30, 12, 36), :ip => '2.3.4.5')

    assert_equal Time.utc(2010, 6, 30, 12, 36), user.last_login_at
    assert_equal '2.3.4.5',                 user.last_login_ip
  end

  test '#can_login? returns false if user is not active' do
    user = Factory(:pending_user)
    assert !user.can_login?
  end

  test 'admin sections' do
    user = Factory(:simple_user)
    assert user.valid?

    user.admin_sections = ['monitoring']

    assert_equal Set[:monitoring], user.admin_sections
    assert user.valid?
  end

  test '#can_login? returns false if user is suspended' do
    user = Factory(:simple_user)
    user.activate!
    user.suspend!

    assert !user.can_login?
  end

  test '#can_login? returns false if the account is pending' do
    account = Factory(:account_without_users)
    user    = Factory(:user, :account => account)

    user.activate!
    account.make_pending!

    assert !user.can_login?
  end

  test '#can_login? returns false if the account is rejected' do
    account = Factory(:account_without_users)
    user    = Factory(:user, :account => account)

    user.activate!
    account.reject!

    assert !user.can_login?
  end

  test '#can_login? returns true if the user is active and the account is approved' do
    account = Factory(:account_without_users)
    user    = Factory(:user, :account => account)

    user.activate!

    assert user.can_login?
  end

  test '#full_name returns full name' do
    user = User.new
    assert user.full_name.blank?

    user.first_name = 'Eric'
    assert_equal 'Eric', user.full_name

    user.first_name = nil
    user.last_name = 'Cartman'
    assert_equal 'Cartman', user.full_name

    user.first_name = ''
    user.last_name = 'Cartman'
    assert_equal 'Cartman', user.full_name

    user.first_name = 'Eric'
    user.last_name = 'Cartman'
    assert_equal 'Eric Cartman', user.full_name
  end

  test '#display_name returns full_name if it is present' do
    user = User.new(:first_name => 'Kyle', :last_name => 'Broflowsky')
    assert_equal 'Kyle Broflowsky', user.display_name
  end

  test '#display_name returns username if full_name is not present' do
    user = User.new(:username => 'ninjaassassin')
    assert_equal 'ninjaassassin', user.display_name
  end

  context 'deletion of users' do
    setup do
      @account = Factory(:account, :org_name => "Alice's web empire")
    end

    context 'with role not admin' do
      setup do
        @not_admin = Factory(:simple_user, :account => @account, :role => :member)
      end

      should 'be allowed' do
        assert_raise ActiveRecord::RecordNotFound do
          @not_admin.destroy.reload
        end
      end

      should 'return true on call to can_be_destroyed?' do
        assert @not_admin.can_be_destroyed?
      end
    end

    context 'with role admin' do
      setup do
        @admin = @account.admins.first
      end

      context 'not being the unique admin' do
        setup do
          @admin = Factory(:user, :account => @account, :role => :admin)
        end

        should 'be allowed' do
          assert @account.admins.length > 1

          assert_raise ActiveRecord::RecordNotFound do
            @admin.destroy.reload
          end
        end

        should 'return true on call to can_be_destroyed?' do
          assert @account.admins.length > 1

          assert @admin.can_be_destroyed?
        end
      end

      context 'being the unique admin' do
        should 'not be allowed' do
          assert @account.admins.length == 1

          @account.admins.first.destroy

          assert @account.admins.length == 1
        end

        should 'return true on call to can_be_destroyed?' do
          assert @account.admins.length == 1

          assert !@account.admins.first.can_be_destroyed?
        end
      end

    end
  end

  context 'webhooks' do
    include WebHookTestHelpers

    setup do
      @buyer = Factory :buyer_account
      @provider = @buyer.provider_account
      @user = @provider.admins.first
    end

    should 'be pushed if the user is created by user' do
      new_user = Factory.build :simple_user, :account => @buyer
      User.current = @user

      fires_webhook(new_user)

      new_user.save!
    end

    should 'not be pushed if the user is not created by user' do
      new_user = Factory.build :simple_user, :account => @buyer
      User.current = nil

      fires_webhook.never
      new_user.save!
    end

    should 'be pushed if the user is updated by user' do
      updated_user = Factory :simple_user, :account => @buyer
      User.current = @user

      fires_webhook(updated_user)

      updated_user.username += " "
      updated_user.save!
    end

    should 'not be pushed if the user is not updated by user' do
      updated_user = Factory :simple_user, :account => @buyer
      User.current = nil

      fires_webhook.never

      updated_user.username += " "
      updated_user.save!
    end

    should 'be pushed asynchronously if the user is destroyed by user' do
      destroyed_user = Factory :simple_user, :account => @buyer
      User.current = @user

      fires_webhook(destroyed_user, 'deleted')

      destroyed_user.destroy
    end

    should 'not be pushed if the user is not destroyed by user' do
      destroyed_user = Factory :simple_user, :account => @buyer
      User.current = nil

      fires_webhook.never

      destroyed_user.destroy
    end

  end

  context 'fields and extra fields' do

    should 'be' do
      assert FieldsDefinition.targets.include?("User")
    end

  end # fields and extra fields

  test '.model_name.human is User' do
    assert User.model_name.human == "User"
  end

  context '#sections' do

    setup do
      @buyer = Factory(:buyer_account)
      @user = @buyer.users.first
    end

    context 'users with no sections' do

      should 'be empty' do
        assert @user.sections.empty?
      end

    end # users with no sections

    context 'users with sections' do
      setup do
        @section = Factory(:cms_section, :public => false,
                           :title => "protected-section",
                           :parent => @buyer.provider_account.sections.root)

        grant_buyer_access_to_section @buyer, @section

      end

      should 'contain account sections' do
        assert @user.sections == [@section]
      end

    end # users with sections
  end # sections

  context 'password strength' do

    setup do
      provider = Factory(:simple_provider)
      @buyer = Factory(:buyer_account, provider_account: provider)
    end

    should 'by default allow weak ones' do
      user = @buyer.users.new :password => "weakpassword", :password_confirmation => "weakpassword"
      user.valid?

      assert user.errors[:password].blank?
    end

    should 'weak password must be 6 chars at least' do
      user = @buyer.users.new :password => "weak", :password_confirmation => "weak"
      user.valid?

      assert !user.errors[:password].blank?
    end

    context 'strong passwords' do
      setup do
        @buyer.provider_account.settings
          .update_attribute :strong_passwords_enabled, true
      end

      context 'existing users' do

        setup do
          @user = @buyer.users.first
          @user.reload
        end

        should 'be valid if not updating the password' do
          @user.last_name = "not updating password"

          @user.valid?
          assert @user.errors[:password].blank?
        end

        should 'be invalid if updating the password' do
          @user.password = "nononono"
          @user.valid?

          assert @user.errors[:password].first == User::STRONG_PASSWORD_FAIL_MSG
        end
      end

      context 'validations' do

        should 'be valid with Uppercases, lowercases, digits and weird characters -+_!$#.@ and longer than 8 characters' do
          user = @buyer.users.new :password => "StrongPass123-+_!$#.@", :password_confirmation => "StrongPass123-+_!$#.@"
          user.valid?

          assert user.errors[:password].blank?
        end

        context 'invalid' do

          should 'be invalid if shorter than 8 characters' do
            user = @buyer.users.new :password => "Pas$123", :password_confirmation => "Pas$123"
            user.valid?

            assert user.errors[:password].first == User::STRONG_PASSWORD_FAIL_MSG
          end

          should 'be invalid if without digits' do
            user = @buyer.users.new :password => "StrongPass-+_!$#.@", :password_confirmation => "StrongPass-+_!$#.@"
            user.valid?

            assert user.errors[:password].first == User::STRONG_PASSWORD_FAIL_MSG
          end

          should 'be invalid if without uppercases' do
            user = @buyer.users.new :password => "strongpass123-+_!$#.@", :password_confirmation => "strongpass123-+_!$#.@"
            user.valid?

            assert user.errors[:password].first == User::STRONG_PASSWORD_FAIL_MSG
          end

          should 'be invalid if without lowercases' do
            user = @buyer.users.new :password => "STRONGPASS-+_!$#.@", :password_confirmation => "STRONGPASS-+_!$#.@"
            user.valid?

            assert user.errors[:password].first == User::STRONG_PASSWORD_FAIL_MSG
          end

          should 'be invalid if has strange characters' do
            user = @buyer.users.new :password => "StrongPass|", :password_confirmation => "StrongPass|"
            user.valid?

            assert user.errors[:password].first == User::STRONG_PASSWORD_FAIL_MSG
          end

          context 'when created from provider' do
            setup do
              @user = @buyer.users.first
              @user.stubs(:password_required?).returns(false) #simulate created by provider
            end

            should 'be invalid if password and password confirmation do not match' do
              refute @buyer.users.first.update_attributes :password => "hola12", :password_confirmation => "hola123"
            end
          end

        end # invalid

      end # validations
    end # strong passwords

  end # passwords

  test 'destroys its invitation' do
    invitation = Factory :invitation, :email => "invited@example.com", :account => Factory(:provider_account)
    user = invitation.make_user :username => "username", :password => "password"
    user.save!

    user.destroy
    assert_raise ActiveRecord::RecordNotFound do
      invitation.reload
    end
  end

  test "kill user sessions but current one" do
    user = Factory :user
    session1 = user.user_sessions.create
    session2 = user.user_sessions.create

    user.kill_user_sessions(session1)

    assert_equal session1, user.user_sessions.reload.first
    assert_equal 1, user.user_sessions.reload.length
  end

end

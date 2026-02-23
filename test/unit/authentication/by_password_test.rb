require 'test_helper'
class Authentication::ByPasswordTest < ActiveSupport::TestCase

  setup do
    provider = FactoryBot.create(:simple_provider)
    @buyer = FactoryBot.create(:buyer_account, provider_account: provider)
    @user_with_password = ->(password) do
      @buyer.users.new username: 'user', email: 'user@example.com', password: password, password_confirmation: password
    end
  end

  attr_reader :user_with_password

  class HasSecurePasswordTest < Authentication::ByPasswordTest
    test 'new user with password_digest' do
      user = user_with_password.call('superSecret1234#')

      assert user.authenticated?('superSecret1234#')
    end
  end

  class WeakPasswordTest < Authentication::ByPasswordTest
    test 'should by default forbid weak ones' do
      user = user_with_password.call('weakpassword')

      assert_not user.valid?
      assert_equal "is too short (minimum is 15 characters)", user.errors[:password].first
    end

    test 'weak password must be present' do
      user = user_with_password.call('')

      assert_not user.valid?
      assert_equal "can't be blank", user.errors.messages[:password].first
    end
  end

  class ExistingUsersTest < Authentication::ByPasswordTest
    setup do
      @user = @buyer.users.first
      @user.reload
    end

    test 'should be valid if not updating the password' do
      @user.last_name = "not updating password"

      @user.valid?
      assert @user.errors[:password].blank?
    end

    test 'should be invalid if updating the password' do
      @user.password = "nononono"
      @user.valid?

      assert_equal "is too short (minimum is 15 characters)", @user.errors[:password].first
    end

    test 'password is not validated when user is sample data' do
      @user.password = "nononono"
      @user.signup_type = :sample_data

      assert @user.valid?
      assert @user.errors[:password].blank?
    end
  end

  class ValidationsTest < Authentication::ByPasswordTest
    test 'should be valid with ASCII printable characters and longer than 15 characters' do
      user = user_with_password.call('StrongPass123-+_!$#.@')

      assert user.valid?
      assert user.errors[:password].blank?
    end

    test 'should be valid with Unicode characters and longer than 15 characters' do
      user = user_with_password.call('contraseña12345')

      assert user.valid?
      assert user.errors[:password].blank?
    end

    test 'should be invalid if shorter than 15 characters' do
      user = user_with_password.call('Pas$123')
      user.valid?

      assert_equal "is too short (minimum is 15 characters)", user.errors[:password].first
    end

    test 'should be invalid if password and password confirmation do not match' do
      @user = @buyer.users.first

      assert_not @buyer.users.first.update password: "superSecret1234#", password_confirmation: "superSecret12345#"
      assert_equal "doesn't match Password", @buyer.users.first.errors[:password_confirmation].first
    end
  end

  class UnicodeNormalizationTest < Authentication::ByPasswordTest
    test 'password is normalized to NFC before saving' do
      # "café" with e + combining acute accent (NFD form)
      password_nfd = "cafe\u0301_secretpass"
      # "café" with precomposed é (NFC form)
      password_nfc = "café_secretpass"

      assert_not_equal password_nfd, password_nfc
      assert_equal password_nfd.unicode_normalize(:nfc), password_nfc

      user = user_with_password.call(password_nfd)
      user.password_confirmation = password_nfd
      user.save!

      assert user.authenticated?(password_nfc), 'Should authenticate with NFC form'
      assert user.authenticated?(password_nfd), 'Should authenticate with NFD form (normalized before comparison)'
    end

    test 'password length is counted after NFC normalization' do
      # 15 characters in NFD (e + combining accent = 2 code points)
      password_nfd = "contraseñas123".unicode_normalize(:nfd)
      # 14 characters in NFC (ñ = 1 code point)
      password_nfc = "contraseñas123".unicode_normalize(:nfc)

      assert_equal 15, password_nfd.length
      assert_equal 14, password_nfc.length

      user = user_with_password.call(password_nfd)
      user.password_confirmation = password_nfd

      assert_not user.valid?, 'Should be invalid because NFC-normalized length is 14 (< 15)'
      assert_equal "is too short (minimum is 15 characters)", user.errors[:password].first
    end

    test 'already NFC-normalized password does not trigger digest regeneration' do
      password = 'superSecret1234#' # ASCII, already NFC

      user = @buyer.users.build(
        username: 'testuser',
        email: 'test@example.com',
        password: password,
        password_confirmation: password
      )

      original_digest = user.password_digest
      user.valid? # triggers before_validation callback

      assert_equal original_digest, user.password_digest, 'Digest should not change for already-normalized password'
    end

    test 'NFD password triggers digest regeneration after normalization' do
      password_nfd = "café_secretpass".unicode_normalize(:nfd)

      user = @buyer.users.build(
        username: 'testuser',
        email: 'test@example.com',
        password: password_nfd,
        password_confirmation: password_nfd
      )

      original_digest = user.password_digest
      user.valid? # triggers before_validation callback

      assert_not_equal original_digest, user.password_digest, 'Digest should change after normalizing NFD to NFC'
    end

    test 'password confirmation is normalized independently' do
      password_nfc = "café_secretpass".unicode_normalize(:nfc)
      password_nfd = "café_secretpass".unicode_normalize(:nfd)

      user = @buyer.users.build(
        username: 'testuser',
        email: 'test@example.com',
        password: password_nfc,
        password_confirmation: password_nfd
      )

      assert user.valid?, 'Should be valid because both password and confirmation normalize to same value'
    end
  end

  class MethodsTest < Authentication::ByPasswordTest
    class ValidatePasswordTest < MethodsTest
      setup do
        @user = @buyer.users.first
        @user.reload
      end

      test 'returns true when password has changed but not persisted' do
        @user.password = 'newpassword12345'

        assert @user.validate_password?
      end

      test 'returns true when password has not changed but user signed up by_user and has no password' do
        @user.password_digest = nil
        @user.signup_type = :new_signup

        assert @user.signup.by_user?
        assert @user.validate_password?
      end

      test 'returns false when password has not changed and user signup was by machine' do
        @user.signup_type = :minimal

        assert @user.signup.machine?
        assert_not @user.validate_password?
      end

      test 'returns false when password has not changed and user signed up by_user but already has a password' do
        @user.signup_type = :new_signup

        assert @user.signup.by_user?
        assert @user.password_digest.present?
        assert_not @user.validate_password?
      end

      test 'returns true when password has changed and user signup is sample data' do
        @user.password = 'newpassword12345'
        @user.signup_type = :sample_data

        assert @user.signup.sample_data?
        assert @user.validate_password?
      end

      test 'returns false when password has not changed and user has existing password regardless of signup type' do
        %i[new_signup minimal api created_by_provider].each do |signup_type|
          @user.signup_type = signup_type
          @user.reload

          assert @user.password_digest.present?
          assert_not @user.validate_password?, "Expected validate_password? to be false for signup_type: #{signup_type}"
        end
      end
    end

    class ValidateStrongPasswordTest < MethodsTest
      setup do
        @user = @buyer.users.first
        @user.reload
      end

      test 'returns false when strong_passwords_disabled is true' do
        Rails.configuration.three_scale.stubs(:strong_passwords_disabled).returns(true)

        @user.password = 'newpassword12345'

        assert_not @user.validate_strong_password?
      end

      test 'returns false when user signup is sample_data' do
        @user.password = 'newpassword12345'
        @user.signup_type = :sample_data

        assert_not @user.validate_strong_password?
      end

      test 'returns true when strong_passwords_disabled is false and not sample_data and validate_password? is true' do
        @user.password = 'newpassword12345'
        @user.signup_type = :new_signup

        assert @user.validate_password?
        assert @user.validate_strong_password?
      end

      test 'returns false when strong_passwords_disabled is false and not sample_data but validate_password? is false' do
        @user.signup_type = :new_signup

        assert_not @user.validate_password?
        assert_not @user.validate_strong_password?
      end
    end

    class UsingPasswordTest < MethodsTest
      setup do
        @user = @buyer.users.first
        @user.reload
      end

      test 'returns true when password is persisted in database' do
        assert @user.password_digest_in_database.present?
        assert @user.already_using_password?
      end

      test 'returns false when password_digest is nil in database' do
        @user.update_column(:password_digest, nil)

        assert_not @user.already_using_password?
      end

      test 'returns false when password is set but not yet persisted' do
        new_user = @buyer.users.build(username: 'newuser', email: 'new@example.com', password: 'testpassword', password_confirmation: 'testpassword')

        assert new_user.password_digest.present?
        assert_not new_user.already_using_password?
      end
    end
  end
end

# frozen_string_literal: true

require 'test_helper'

class Liquid::Drops::UserDropTest < ActiveSupport::TestCase
  include Liquid

  setup do
    @buyer = FactoryBot.create(:buyer_account)
    @user = @buyer.users.first
    @drop = Drops::User.new(@user)
  end

  class NoCurrentUserTest < Liquid::Drops::UserDropTest
    test '#display_name' do
      assert_equal @user.decorate.display_name, @drop.display_name
    end

    test '#informal_name' do
      assert_equal @user.decorate.informal_name, @drop.informal_name
    end

    test '#name' do
      assert_equal @user.decorate.full_name, @drop.name
    end

    def test_oauth2
      @user.signup.expects(:oauth2?).returns(true)
      assert @drop.oauth2?

      @user.signup.expects(:oauth2?).returns(false)
      assert_not @drop.oauth2?
    end

    test 'returns roles_collection' do
      User.current = @user
      assert_kind_of Array, @drop.roles_collection
      assert_kind_of Liquid::Drops::User::Role, @drop.roles_collection[0]
    end

    test 'returns url' do
      assert_equal "/admin/account/users/#{@user.id}", @drop.url
    end

    test 'returns edit_url' do
      assert_equal "/admin/account/users/#{@user.id}/edit", @drop.edit_url
    end

    test 'returns the role as string' do
      assert_equal(@user.role.to_s, @drop.role)
    end

    test '#using_password?' do
      assert @drop.using_password?

      without_password_drop = Drops::User.new(FactoryBot.create(:user, account: @buyer, password_digest: nil))
      assert_not without_password_drop.using_password?
    end

    test '#using_password? returns false when password is set but not persisted' do
      new_user = @buyer.users.build(username: 'newuser', email: 'new@example.com', password: 'testpassword', password_confirmation: 'testpassword')
      new_user_drop = Drops::User.new(new_user)

      assert_not new_user_drop.using_password?
    end

    test '#password_required? returns true when signup is by_user' do
      @user.signup_type = :new_signup

      assert @user.signup.by_user?
      assert @drop.password_required?
    end

    test '#password_required? returns false when signup is machine' do
      @user.signup_type = :minimal

      assert @user.signup.machine?
      assert_not @drop.password_required?
    end

    test '#password_required? returns false for sample_data signup' do
      @user.signup_type = :sample_data

      assert @user.signup.sample_data?
      assert_not @drop.password_required?
    end
  end

  class BuyerUserTest < Liquid::Drops::UserDropTest
    setup do
      ::User.current = @user

      @drop2 = Drops::User.new(FactoryBot.create(:user, account: @buyer))
    end

    test "can be destroyed" do
      assert @drop2.can.be_destroyed?
    end

    test "can be managed" do
      assert @drop2.can.be_managed?
    end

    test "can be update role" do
      assert @drop2.can.be_update_role?
    end
  end

  class NormalUserTest < Liquid::Drops::UserDropTest
    setup do
      ::User.current = FactoryBot.create(:user, account: @buyer)
    end

    test "can't be destroyed" do
      assert_not @drop.can.be_destroyed?
    end

    test "can't be managed" do
      assert_not @drop.can.be_managed?
    end

    test "can't be update role" do
      assert_not @drop.can.be_update_role?
    end
  end

  class SectionsTest < Liquid::Drops::UserDropTest
    test 'users with no sections should be empty' do
      user_drop = Drops::User.new(@user)
      assert user_drop.sections.empty?
    end

    test 'users with sections should return sections paths' do
      @section = FactoryBot.create(:cms_section, public: false,
                                                 provider: @buyer.provider_account,
                                                 title: "protected-section",
                                                 parent: @buyer.provider_account.sections.root)
      grant_buyer_access_to_section @buyer, @section
      user_drop = Drops::User.new(@user)
      assert_equal ["/protected-section"], user_drop.sections
    end
  end

  class FieldDefinitionsTest < Liquid::Drops::UserDropTest
    setup do
      [{ target: "User", name: "first_name",    label: "first_name", hidden: true },
       { target: "User", name: "visible_extra", label: "visible_extra" },
       { target: "User", name: "hidden_extra",  label: "hidden_extra", hidden: true }]
       .each do |field|
        FactoryBot.create :fields_definition, field.merge({account_id: @buyer.provider_account.id})
      end

      @buyer.reload
      @user = FactoryBot.create :user, account: @buyer
      @user.extra_fields = {"visible_extra" => "visible extra value", "hidden_extra" => "hidden extra value" }
      @user.save!

      @drop = Drops::User.new(@user)
    end

    test '#fields' do
      assert @drop.fields.first.is_a?(Drops::Field)
    end

    test '#fields should contain both visible and invisible' do
      @user.username = 'someone'
      @user.first_name = 'John'

      assert_equal 'someone', @drop.fields["username"].to_str
      assert_equal 'John', @drop.fields["first_name"].to_str
    end

    test '#fields should include extra fields and builtin fields' do
      #regression test
      assert_not_nil @drop.fields["visible_extra"]
      assert_not_nil @drop.fields["first_name"]
      assert_not_nil @drop.fields["username"]
    end

    test 'should be fields' do
      assert @drop.extra_fields.first.is_a?(Drops::Field)
    end

    test '#extra visible and invisible' do
      assert_equal "visible extra value", @drop.extra_fields["visible_extra"]
      assert_equal "hidden extra value", @drop.extra_fields["hidden_extra"]
    end

    test 'should not return builtin fields' do
      assert_nil @drop.extra_fields["username"]
    end
  end
end

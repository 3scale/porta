require 'test_helper'

class Liquid::Drops::UserDropTest < ActiveSupport::TestCase
  include Liquid


  def setup
    @buyer = Factory(:buyer_account)
    @user = @buyer.users.first
    @drop = Drops::User.new(@user)
  end

  def test_oauth2
    @user.signup.expects(:oauth2?).returns(true)
    assert @drop.oauth2?

    @user.signup.expects(:oauth2?).returns(false)
    refute @drop.oauth2?
  end

  should 'returns roles_collection' do
    User.current = @user
    assert_kind_of Array, @drop.roles_collection
    assert_kind_of Liquid::Drops::User::Role, @drop.roles_collection[0]
  end

  should 'returns url' do
    assert_equal "/admin/account/users/#{@user.id}", @drop.url
  end

  should 'returns edit_url' do
    assert_equal "/admin/account/users/#{@user.id}/edit", @drop.edit_url
  end

  should 'return the role as string' do
    assert_equal(@user.role.to_s, @drop.role)
  end


  context 'by a buyer' do
    setup do
      ::User.current = @user

      @drop2 = Drops::User.new(Factory.create(:user, account: @buyer))

    end

    should "can be destroyed" do
      assert @drop2.can.be_destroyed?
    end

    should "can be managed" do
      assert @drop2.can.be_managed?
    end

    should "can be update role" do
      assert @drop2.can.be_update_role?
    end

  end

  context 'by a normal user' do
    setup do
      ::User.current = Factory.create(:user, account: @buyer)
    end

    should "can't be destroyed" do
      assert !@drop.can.be_destroyed?
    end

    should "can't be managed" do
      assert !@drop.can.be_managed?
    end

    should "can't be update role" do
      assert !@drop.can.be_update_role?
    end

  end

  context '#sections' do
    context 'users with no sections' do

      should 'be empty' do
        user_drop = Drops::User.new(@user)
        assert user_drop.sections.empty?
      end

    end # users with no sections

    context 'users with sections' do
      setup do
        @section = Factory(:cms_section, :public => false,
                           :provider => @buyer.provider_account,
                           :title => "protected-section",
                           :parent => @buyer.provider_account.sections.root)
        grant_buyer_access_to_section @buyer, @section
      end

      should 'return sections paths' do
        user_drop = Drops::User.new(@user)
        assert user_drop.sections == ["/protected-section"]
      end

    end # users with sections
  end # sections

  context "field definitions" do
    setup do
      [{ target: "User", name: "first_name",    label: "first_name", hidden: true },
       { target: "User", name: "visible_extra", label: "visible_extra" },
       { target: "User", name: "hidden_extra",  label: "hidden_extra", hidden: true }]
       .each do |field|
         Factory :fields_definition, field.merge({account_id: @buyer.provider_account.id})
      end

      @buyer.reload
      @user = Factory :user, account: @buyer
      @user.extra_fields = {"visible_extra" => "visible extra value", "hidden_extra" => "hidden extra value" }
      @user.save!

      @drop = Drops::User.new(@user)
    end

    should '#fields' do
      assert @drop.fields.first.is_a?(Drops::Field)
    end

    should '#fields contain both visible and invisible' do
      @user.username = 'someone'
      @user.first_name = 'John'

      assert_equal 'someone', @drop.fields["username"].to_str
      assert_equal 'John', @drop.fields["first_name"].to_str
    end

    should '#fields include extra fields and builtin fields' do
      #regression test
      assert_not_nil @drop.fields["visible_extra"]
      assert_not_nil @drop.fields["first_name"]
      assert_not_nil @drop.fields["username"]
    end

    should 'be fields' do
      assert @drop.extra_fields.first.is_a?(Drops::Field)
    end

    should '#extra visible and invisible' do
      assert_equal "visible extra value", @drop.extra_fields["visible_extra"]
      assert_equal "hidden extra value", @drop.extra_fields["hidden_extra"]
    end

    should 'not return builtin fields' do
      assert_nil @drop.extra_fields["username"]
    end

  end # field definitions
end

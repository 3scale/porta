require 'test_helper'

class Abilities::MultipleApplicationsTest < ActiveSupport::TestCase

  def setup
    @provider = FactoryBot.create(:provider_account)
    @admin = @provider.admins.first
    @member = FactoryBot.create(:user, :account => @provider, :role => :member)
  end

  context "switch multiple applications denied" do
    setup do
      assert @provider.settings.multiple_applications.denied?
    end

    should "admin cannot manage multiple apps" do
      admin_ability = Ability.new(@admin)

      assert_can    admin_ability, :admin,  :multiple_applications

      assert_cannot admin_ability, :see,    :multiple_applications
      assert_cannot admin_ability, :manage, :multiple_applications
    end

    should "member cannot manage multiple apps" do
      member_ability = Ability.new(@member)

      assert_cannot member_ability, :see,    :multiple_applications
      assert_cannot member_ability, :admin,  :multiple_applications
      assert_cannot member_ability, :manage, :multiple_applications
    end
  end

  context "switch multiple applications allowed" do
    setup do
      @provider.settings.allow_multiple_applications!
      assert @provider.settings.multiple_applications.allowed?
    end

    should "admin can manage multiple apps" do
      admin_ability = Ability.new(@admin)

      assert_can admin_ability, :see,    :multiple_applications
      assert_can admin_ability, :admin,  :multiple_applications
      assert_can admin_ability, :manage, :multiple_applications
    end

    should "member cannot manage multiple apps" do
      member_ability = Ability.new(@member)

      assert_can    member_ability, :see,    :multiple_applications
      assert_cannot member_ability, :admin,  :multiple_applications
      assert_cannot member_ability, :manage, :multiple_applications
    end

    should "member with partners group can manage multiple apps" do
      #setup
      @member.admin_sections=['partners']

      partners_ability = Ability.new(@member)

      assert_can partners_ability, :see,    :multiple_applications
      assert_can partners_ability, :admin,  :multiple_applications
      assert_can partners_ability, :manage, :multiple_applications
    end
  end
end

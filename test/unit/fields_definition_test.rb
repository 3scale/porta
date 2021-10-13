require 'test_helper'

class FieldsDefinitionTest < ActiveSupport::TestCase

  test 'visible_for?' do
    provider_account = FactoryBot.create(:provider_account)
    provider_user = provider_account.first_admin

    buyer_user = FactoryBot.create(:buyer_account).first_admin
    other_provider_user = FactoryBot.create(:provider_account).first_admin

    #
    # With a hidden field
    #
    fd = FactoryBot.create(:fields_definition, account: provider_account, hidden: true)

    # For a buyer
    refute fd.visible_for?(buyer_user)

    # For other provider account
    refute fd.visible_for?(other_provider_user)

    # For the owner
    assert fd.visible_for?(provider_user)

    #
    # With a visible field
    #
    fd = FactoryBot.create(:fields_definition, account: provider_account, hidden: false)

    # For a buyer
    assert fd.visible_for?(buyer_user)

    # For other provider account
    assert fd.visible_for?(other_provider_user)

    # For the owner
    assert fd.visible_for?(provider_user)
  end

  should 'not set unregistered target' do
    fd = FieldsDefinition.new
    assert FieldsDefinition.targets.exclude?("Foo")

    fd.target = "Foo"
    assert fd.target.nil?
  end

  context "validations" do
    setup do
      @provider = FactoryBot.create(:provider_account)
      FieldsDefinition.where(:account_id => @provider.id).delete_all # removing default ones
      @field_definition1 = FieldsDefinition.create(:account => @provider, :name => 'org_name', :target => 'Account', :label => 'foo')
    end

    should validate_presence_of :name
    should validate_presence_of :label
    should validate_presence_of :target

    should "err on equal name for the same target and provider" do
      assert_raise ActiveRecord::RecordInvalid do
        FieldsDefinition.create!(:account => @provider, :name => 'org_name', :target => 'Account', :label => 'bar2')
      end
    end

    should "not allow non alphanumeric characters in name" do
      f = FieldsDefinition.new(:account => @provider, :name => 'with space', :target => 'Account', :label => 'bar2i')
      assert !f.valid?

      f.name = "5numbercannotbefirstdigit"
      assert !f.valid?

      f.name = "_underscorecannotbefirstdigit"
      assert !f.valid?

      f.name = "-dashcannotbefirstdigit"
      assert !f.valid?

      f.name = "onlyletters"
      assert f.valid?

      f.name = "using_underscore"
      assert f.valid?

      f.name = "using-dash"
      assert f.valid?

      f.name = "using-numbers-123"
      assert f.valid?
    end

    should "allow always modifications on label" do
      assert_nothing_raised do
        FieldsDefinition.create!(:account => @provider, :target => 'User', :name => 'username', :label => 'foo')
        FieldsDefinition.create!(:account => @provider, :target => 'User', :name => 'first_name', :label => 'bar')
        FieldsDefinition.create!(:account => @provider, :target => 'User', :name => 'new_field', :label => 'baz')
      end
    end

    should "not destroy non modifiable fields" do
      assert_no_difference 'FieldsDefinition.count' do
        @field_definition1.destroy
      end
    end

    should "set required, editable and visible properties to required field on target" do
      field = FieldsDefinition.create(:account => @provider, :target => 'User', :name => 'username', :label => 'foo', :required => false, :hidden => true, :read_only => true)
      assert field.required
      assert !field.hidden
      assert !field.read_only
    end

    context "builtin fields" do

      context "required field on target" do

        should " allow choices property" do
          fd = FieldsDefinition.new(:account => @provider,
                                    :target => 'User', :name => 'username',
                                    :choices => ["opt1", "opt2"], :label => 'foo')
          assert fd.valid?
        end

      end

      context "and are modifiable fields" do
        should "not allow hidden AND required" do
          a = FieldsDefinition.new(:account => @provider, :target => 'User',
                                   :name => 'first_name',
                                   :hidden => true,
                                   :label => 'first_name',
                                   :required => true)
          assert !a.valid?
        end

        should "not allow readonly AND required" do
          a = FieldsDefinition.new(:account => @provider, :target => 'User',
                                   :name => 'first_name',
                                   :read_only => true,
                                   :required => true)
          assert !a.valid?
        end

        should "allow choices property only on string fields" do  #if type = string?
          a = FieldsDefinition.new(:account => @provider, :label => 'lal', :target => 'User', :name => 'first_name', :choices => ["a", "b"])
          assert a.valid?

          a = FieldsDefinition.new(:account => @provider, :label => 'country', :target => 'Account', :name => 'country', :choices => ["a", "b"])

          refute a.valid?
        end


      end

    end # validations

    context "choices are serialized correctly" do
      setup do
        @fd = FieldsDefinition.new(:account => @provider, :label => 'lal', :target => 'User', :name => 'first_name', :choices => ["a", "b"])
      end

      should "serialize choices as an array" do
        assert @fd.choices.is_a? Array
      end

      should "serialize choices without nesting" do
        assert_equal 'a', @fd.choices.first
      end

      context "get/save choices as an array on choices_for_views" do
        should "work with comma" do
          @fd.choices_for_views= "changed,values"
          assert_equal ['changed', 'values'], @fd.choices
          assert_equal 'changed, values', @fd.choices_for_views
          @fd.choices_for_views= "changed, values"
          assert_equal ['changed', 'values'],  @fd.choices
          assert_equal 'changed, values', @fd.choices_for_views
        end

        should "work with new line" do
          @fd.choices_for_views= "Yes, I'm \n No, I'm not"
          assert_equal ["Yes, I'm", "No, I'm not"], @fd.choices
          assert_equal "Yes, I'm\nNo, I'm not", @fd.choices_for_views
        end

        should "work with nil" do
          @fd.choices_for_views= nil
          assert_equal [], @fd.choices
        end
      end
    end
  end

  context  "not in database" do
    context "modificable fields" do
      should "not allow hidden AND required" do
        fd = FieldsDefinition.new(:account => @provider, :target => 'User',
                                  :name => 'new_field',
                                  :hidden => true,
                                  :label => 'lal',
                                  :required => true)
        assert !fd.valid?
        fd.hidden = false
        assert fd.valid?
      end

      should "not allow readonly AND required" do
        fd = FieldsDefinition.new(:account => @provider, :target => 'User',
                                  :name => 'new_field',
                                  :read_only => true,
                                  :label => 'lal',
                                  :required => true)
        assert !fd.valid?
        fd.read_only = false
        assert fd.valid?
      end

      should "allow choices property " do  #if type = string?
        a = FieldsDefinition.new(:account => @provider, :label => 'lal', :target => 'User', :name => 'first_name', :choices => ["a", "b"])
        assert a.valid?
      end
    end
  end

  context '.editable_by' do
    setup do
      @provider = FactoryBot.create :provider_account
      FieldsDefinition.delete_all
      FactoryBot.create(:fields_definition, :account => @provider, :name => "hidden",
              :hidden => true)
      FactoryBot.create(:fields_definition, :account => @provider, :name => "read_only",
              :read_only => true)
      @public_field = FactoryBot.create(:fields_definition, :account => @provider,
                              :name => "public")
      @buyer = FactoryBot.create :buyer_account, :provider_account => @provider
    end

    should 'return all fields for provider users' do
      assert FieldsDefinition.editable_by(@provider.users.first) ==
	           FieldsDefinition.all
    end

    should 'return only public fields to buyer users' do
      assert FieldsDefinition.editable_by(@buyer.users.first) == [@public_field]
    end

    should 'return only public fields to non user' do
      assert FieldsDefinition.editable_by(nil) == [@public_field]
    end

  end

  context 'positions' do
    setup do
      @provider = FactoryBot.create :provider_account
      FieldsDefinition.delete_all
      @hidden = FactoryBot.create(:fields_definition, account: @provider, name: 'hidden', hidden: true)
      @read_only = FactoryBot.create(:fields_definition, account: @provider, name: 'read_only', read_only: true)
      @required = FactoryBot.create(:fields_definition, account: @provider, name: 'required', required: true)
      @acc_target = FactoryBot.create(:fields_definition, account: @provider, name: 'other', required: true, target: 'Account')
      @acc_target_another = FactoryBot.create(:fields_definition, account: @provider, name: 'other2', required: true, target: 'Account')
    end

    should 'return correct positions' do
      assert_equal @hidden.pos, @read_only.pos - 1
      assert_equal @read_only.pos, @required.pos  - 1
    end

    should 'change position when updated' do
      hidden_pos, read_only_pos = @hidden.pos, @read_only.pos
      required_pos, acc_target_pos = @required.pos, @acc_target.pos
      acc_target_another_pos = @acc_target_another.pos

      @read_only.update_attribute(:pos, read_only_pos - 1)

      assert_equal @read_only.reload.pos, hidden_pos
      assert_equal @hidden.reload.pos, read_only_pos
      assert_equal @required.reload.pos, required_pos
      assert_equal @acc_target.reload.pos, acc_target_pos
      assert_equal @acc_target_another.reload.pos, acc_target_another_pos
    end

    should 'not change the position when update fails' do
      hidden_pos, read_only_pos = @hidden.pos, @read_only.pos
      required_pos, acc_target_pos = @required.pos, @acc_target.pos
      acc_target_another_pos = @acc_target_another.pos

      @required.update(position: 1, name: '%*&#^%@)*$')

      assert_not @required.errors.empty?
      assert_equal @hidden.reload.pos, hidden_pos
      assert_equal @read_only.reload.pos, read_only_pos
      assert_equal @required.reload.pos, required_pos
      assert_equal @acc_target.reload.pos, acc_target_pos
      assert_equal @acc_target_another.reload.pos, acc_target_another_pos
    end
  end
end

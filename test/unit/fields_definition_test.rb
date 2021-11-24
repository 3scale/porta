# frozen_string_literal: true

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
    assert_not fd.visible_for?(buyer_user)

    # For other provider account
    assert_not fd.visible_for?(other_provider_user)

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

  test 'not set unregistered target' do
    fd = FieldsDefinition.new
    assert FieldsDefinition.targets.exclude?("Foo")

    fd.target = "Foo"
    assert fd.target.nil?
  end

  test "not in database modificable fields not allow hidden AND required" do
    fd = FieldsDefinition.new(:account => @provider, :target => 'User',
                              :name => 'new_field',
                              :hidden => true,
                              :label => 'lal',
                              :required => true)
    assert_not fd.valid?
    fd.hidden = false
    assert fd.valid?
  end

  test "not in database modificable fields not allow readonly AND required" do
    fd = FieldsDefinition.new(:account => @provider, :target => 'User',
                              :name => 'new_field',
                              :read_only => true,
                              :label => 'lal',
                              :required => true)
    assert_not fd.valid?
    fd.read_only = false
    assert fd.valid?
  end

  test "not in database modificable fields allow choices property " do  #if type = string?
    a = FieldsDefinition.new(:account => @provider, :label => 'lal', :target => 'User', :name => 'first_name', :choices => %w[a b])
    assert a.valid?
  end
end

class ValidationTest < ActiveSupport::TestCase
  def setup
    @provider = FactoryBot.create(:provider_account)
    FieldsDefinition.where(:account_id => @provider.id).delete_all # removing default ones
    @field_definition1 = FieldsDefinition.create(:account => @provider, :name => 'org_name', :target => 'Account', :label => 'foo')

    @fd = FieldsDefinition.new(:account => @provider, :label => 'lal', :target => 'User', :name => 'first_name', :choices => %w[a b])
  end

  test 'validate presence of' do
    assert validate_presence_of :name
    assert validate_presence_of :label
    assert validate_presence_of :target
  end

  test "err on equal name for the same target and provider" do
    assert_raise ActiveRecord::RecordInvalid do
      FieldsDefinition.create!(:account => @provider, :name => 'org_name', :target => 'Account', :label => 'bar2')
    end
  end

  test "not allow non alphanumeric characters in name" do
    f = FieldsDefinition.new(:account => @provider, :name => 'with space', :target => 'Account', :label => 'bar2i')
    assert_not f.valid?

    f.name = "5numbercannotbefirstdigit"
    assert_not f.valid?

    f.name = "_underscorecannotbefirstdigit"
    assert_not f.valid?

    f.name = "-dashcannotbefirstdigit"
    assert_not f.valid?

    f.name = "onlyletters"
    assert f.valid?

    f.name = "using_underscore"
    assert f.valid?

    f.name = "using-dash"
    assert f.valid?

    f.name = "using-numbers-123"
    assert f.valid?
  end

  test "allow always modifications on label" do
    assert_nothing_raised do
      FieldsDefinition.create!(:account => @provider, :target => 'User', :name => 'username', :label => 'foo')
      FieldsDefinition.create!(:account => @provider, :target => 'User', :name => 'first_name', :label => 'bar')
      FieldsDefinition.create!(:account => @provider, :target => 'User', :name => 'new_field', :label => 'baz')
    end
  end

  test "not destroy non modifiable fields" do
    assert_no_difference 'FieldsDefinition.count' do
      @field_definition1.destroy
    end
  end

  test "set required, editable and visible properties to required field on target" do
    field = FieldsDefinition.create(:account => @provider, :target => 'User', :name => 'username', :label => 'foo', :required => false, :hidden => true, :read_only => true)
    assert field.required
    assert_not field.hidden
    assert_not field.read_only
  end

  test "builtin fields required field on target allow choices property" do
    fd = FieldsDefinition.new(:account => @provider,
                              :target => 'User', :name => 'username',
                              :choices => %w[opt1 opt2], :label => 'foo')
    assert fd.valid?
  end

  test "builtin fields and are modifiable fields not allow hidden AND required" do
    a = FieldsDefinition.new(:account => @provider, :target => 'User',
                              :name => 'first_name',
                              :hidden => true,
                              :label => 'first_name',
                              :required => true)
    assert_not a.valid?
  end

  test "builtin fields and are modifiable fields not allow readonly AND required" do
    a = FieldsDefinition.new(:account => @provider, :target => 'User',
                              :name => 'first_name',
                              :read_only => true,
                              :required => true)
    assert_not a.valid?
  end

  test "builtin fields and are modifiable fields allow choices property only on string fields" do  #if type = string?
    a = FieldsDefinition.new(:account => @provider, :label => 'lal', :target => 'User', :name => 'first_name', :choices => %w[a b])
    assert a.valid?

    a = FieldsDefinition.new(:account => @provider, :label => 'country', :target => 'Account', :name => 'country', :choices => %w[a b])

    assert_not a.valid?
  end

  test "serialize choices as an array" do
    assert @fd.choices.is_a? Array
  end

  test "serialize choices without nesting" do
    assert_equal 'a', @fd.choices.first
  end

  test "get/save choices as an array on choices_for_views work with comma" do
    @fd.choices_for_views= "changed,values"
    assert_equal %w[changed values], @fd.choices
    assert_equal 'changed, values', @fd.choices_for_views
    @fd.choices_for_views= "changed, values"
    assert_equal %w[changed values],  @fd.choices
    assert_equal 'changed, values', @fd.choices_for_views
  end

  test "get/save choices as an array on choices_for_views work with new line" do
    @fd.choices_for_views= "Yes, I'm \n No, I'm not"
    assert_equal ["Yes, I'm", "No, I'm not"], @fd.choices
    assert_equal "Yes, I'm\nNo, I'm not", @fd.choices_for_views
  end

  test "get/save choices as an array on choices_for_views work with nil" do
    @fd.choices_for_views= nil
    assert_equal [], @fd.choices
  end
end

class EditableByTest < ActiveSupport::TestCase
  def setup
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

  test 'return all fields for provider users' do
    assert_equal FieldsDefinition.editable_by(@provider.users.first),FieldsDefinition.all
  end

  test 'return only public fields to buyer users' do
    assert_equal FieldsDefinition.editable_by(@buyer.users.first), [@public_field]
  end

  test 'return only public fields to non user' do
    assert_equal FieldsDefinition.editable_by(nil), [@public_field]
  end
end

class PositionsTest < ActiveSupport::TestCase
  def setup
    @provider = FactoryBot.create :provider_account
    FieldsDefinition.delete_all
    @hidden = FactoryBot.create(:fields_definition, account: @provider, name: 'hidden', hidden: true)
    @read_only = FactoryBot.create(:fields_definition, account: @provider, name: 'read_only', read_only: true)
    @required = FactoryBot.create(:fields_definition, account: @provider, name: 'required', required: true)
    @acc_target = FactoryBot.create(:fields_definition, account: @provider, name: 'other', required: true, target: 'Account')
    @acc_target_another = FactoryBot.create(:fields_definition, account: @provider, name: 'other2', required: true, target: 'Account')
  end

  test 'return correct positions' do
    assert_equal @hidden.pos, @read_only.pos - 1
    assert_equal @read_only.pos, @required.pos  - 1
  end

  test 'change position when updated' do
    hidden_pos = @hidden.pos
    read_only_pos = @read_only.pos
    required_pos = @required.pos
    acc_target_pos = @acc_target.pos
    acc_target_another_pos = @acc_target_another.pos

    @read_only.update(pos: read_only_pos - 1)

    assert_equal @read_only.reload.pos, hidden_pos
    assert_equal @hidden.reload.pos, read_only_pos
    assert_equal @required.reload.pos, required_pos
    assert_equal @acc_target.reload.pos, acc_target_pos
    assert_equal @acc_target_another.reload.pos, acc_target_another_pos
  end

  test 'not change the position when update fails' do
    hidden_pos = @hidden.pos
    read_only_pos = @read_only.pos
    required_pos = @required.pos
    acc_target_pos = @acc_target.pos
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

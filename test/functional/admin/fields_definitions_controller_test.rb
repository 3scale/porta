require 'test_helper'

class Admin::FieldsDefinitionsControllerTest < ActionController::TestCase

  def setup
    @provider = FactoryBot.create(:provider_account)
    login_provider @provider
  end


  def field_definition
    @field_definition ||= FactoryBot.create(:fields_definition, account: @provider)
  end

  test 'index' do
    get :index

    assert_response :success
  end

  test 'show' do
    get :show, id: field_definition

    assert_response :success
  end

  test 'edit' do
    get :edit, id: field_definition

    assert_response :success
  end

  test 'create' do
    post :create, fields_definition: { target: 'User', name: 'some_field', label: 'some_field' }
    assert_redirected_to action: :index

    field = FieldsDefinition.last!

    assert_equal 'some_field', field.name
    assert_equal 'some_field', field.label
    assert_equal 'User', field.target
  end

  test 'update' do
    put :update, id: field_definition, fields_definition: { label: 'super_random_new_name' }
    assert_redirected_to action: :index

    field = FieldsDefinition.last!
    assert_equal 'super_random_new_name', field.label
  end

  test 'update fails' do
    FieldsDefinition.any_instance.stubs(:save).returns(false)
    put :update, id: field_definition
    assert assigns(:required_fields)
  end


  test 'destroy' do
    delete :destroy, id: field_definition
    assert_redirected_to action: :index

    assert_raise(ActiveRecord::RecordNotFound) do
      field_definition.reload
    end
  end

  test 'sort' do
    FieldsDefinition.delete_all

    other = FactoryBot.create(:fields_definition, account: @provider, target: 'Account', pos: 1)
    field_definition = FactoryBot.create(:fields_definition, account: @provider, pos: 2)

    assert_equal [other, field_definition], @provider.fields_definitions(true).order(:id).to_a

    post :sort, fields_definition: [ field_definition.id, other.id ]
    assert_response :success
    fields = @provider.fields_definitions(true)

    assert_equal [1, 2], fields.pluck(:pos)
    assert_equal [field_definition, other],fields.to_a
  end
end

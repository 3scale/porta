require 'test_helper'

class DeveloperPortal::Admin::AccountsControllerTest < DeveloperPortal::ActionController::TestCase
  include FieldsDefinitionsHelpers

  setup do
    @provider = FactoryBot.create(:simple_provider)
    @buyer = FactoryBot.create(:buyer_account, provider_account: @provider)
    FieldsDefinition.create_defaults!(@provider)

    host! @provider.internal_domain
    login_as @buyer.first_admin
  end

  test "update without account params should respond with 400" do
    put :update
    assert_response 400
  end

  test "extra fields can be updated, except vat_rate" do
    field_defined(@provider, { target: "Account", name: "custom_field" })
    field_defined(@provider, { target: "Account", name: "vat_rate" })

    assert_nil @buyer.vat_rate

    put :update, params: {
      account: {
        org_name: 'New name',
        custom_field: 'test',
        vat_rate: 10
      }
    }

    assert_redirected_to '/admin/account'
    @buyer.reload

    assert_equal 'New name', @buyer.org_name
    assert_equal 'test', @buyer.extra_fields['custom_field']
    assert_nil @buyer.vat_rate
  end

  test 'update country only when not read-only' do
    country_field = field_defined(@provider, { target: "Account", name: "country" })

    original_country = @buyer.country
    assert_not_nil original_country

    country = FactoryBot.create(:country, code: "SL", name: "Superland")

    put :update, params: { account: { country_id: country.id } }

    assert_equal 'Superland', @buyer.reload.country.name

    country_field.update(read_only: true)

    put :update, params: { account: { country_id: original_country.id } }

    assert_equal 'Superland', @buyer.reload.country.name
  end
end

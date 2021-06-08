require 'rails_helper'

resource 'FieldsDefinition' do
  let(:resource) { FactoryBot.create(:fields_definition,
                                     account: provider,
                                     target: 'Account',
                                     name: 'stuff',
                                     choices: %w[Orange Apple Banana]) }
  let(:expected_properties) { %i[target label name choices required hidden read_only position] }

  api 'fields definition', options = { format: [:json] } do
    get "/admin/api/fields_definitions/:id.:format", action: :show do
      before { resource.reload }
    end

    post "/admin/api/fields_definitions.:format", action: :create do
      before { resource.reload }

      parameter :name, 'Fields definition name'
      parameter :label, 'Fields definition title that developers will see'
      parameter :target, 'Target entity of fields definition.'
      let(:name) { 'myname' }
      let(:label) { 'mylabel' }
      let(:target) { 'User' }
    end

    put "/admin/api/fields_definitions/:id.:format", action: :update do
      parameter :label, 'Fields definition title that developers will see'
      parameter :target, 'Target entity of fields definition.'
      let(:label) { 'another label' }
      let(:target) { 'Account' }
    end
  end
  json(:resource) do
    let(:root) { 'fields_definition' }

    it { should have_properties(expected_properties).from(resource) }
  end

end

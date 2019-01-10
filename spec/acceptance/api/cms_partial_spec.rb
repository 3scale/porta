require 'rails_helper'

resource "CMS::Partial" do

  let(:resource) do
    FactoryBot.create(:cms_partial, body: 'body', draft: 'draft',
            system_name: 'some-partial', liquid_enabled: false, handler: 'markdown')
  end

  json(:resource) do
    let(:root) { 'partial' }
    it { should have_properties('id', 'system_name', 'handler', 'liquid_enabled').from(resource) }
  end
end

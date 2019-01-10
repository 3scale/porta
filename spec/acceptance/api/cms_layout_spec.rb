require 'rails_helper'

resource "CMS::Layout" do

  let(:resource) { FactoryBot.create(:cms_layout, body: 'body', draft: 'draft') }

  json(:resource) do
    let(:root) { 'layout' }
    it { should have_properties('id', 'content_type', 'handler', 'system_name', 'title').from(resource) }
  end
end

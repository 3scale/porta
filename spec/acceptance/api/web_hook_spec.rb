require 'rails_helper'

resource "WebHook" do

  let(:resource) { FactoryBot.create(:web_hook, account: provider) }

  api 'webhooks', format: [:json] do
    put '/admin/api/webhooks.json', action: :update do
      parameter(:active, 'Activate/Disable WebHooks')
      let(:active) { false }
    end
  end

  json(:resource) do
    let(:root) { 'webhook' }
    it { should have_properties('active', 'url', 'provider_actions').from(resource) }
  end
end

__END__
admin_api_webhooks PUT /admin/api/webhooks(.:format) admin/api/web_hooks#update {:format=>"json"}

require 'rails_helper'

resource "WebHook::Failure" do
  let(:collection) { WebHookFailures.new(provider.id) }
  let(:resource) { WebHook::Failure.new('exception', '12345', 'some-url', '<xml/>', Time.parse('2010-01-01')) }
  let(:resource_representer) { 'WebHookFailureRepresenter' }
  let(:collection_representer) { 'WebHookFailuresRepresenter' }

  api 'webhook failure' do
    before { collection.add(resource) }

    get '/admin/api/webhooks/failures.:format', :collection do
      request "List #{models}"
    end

    delete '/admin/api/webhooks/failures.:format', :collection do
      parameter :time, 'Destroy WebHook Failures with time less then or equal to passed value'
      let(:time) { '2012-01-01' }

      request "Destroy #{models}", body: false do
        collection.all.should be_empty
      end
    end
  end

  json(:resource) do
    before { resource.stub(:save!) }

    let(:root) { 'webhooks-failure' }
    it do
      should include('id' => '12345', 'time' => Time.parse('2010-01-01').as_json,
                     'error' => 'exception', 'url' => 'some-url', 'event' => '<xml/>')
    end
  end

  json(:collection) do
    let(:root) { 'webhooks-failures' }
    it { should be_an(Array) }
  end
end

__END__

admin_api_webhooks_failures GET    /admin/api/webhooks/failures(.:format) admin/api/web_hooks_failures#show {:format=>"xml"}
                            DELETE /admin/api/webhooks/failures(.:format) admin/api/web_hooks_failures#destroy {:format=>"xml"}

require 'rails_helper'

resource "Message" do

  let(:buyer) { FactoryBot.create(:buyer_account, provider_account: provider) }
  let(:resource) { FactoryBot.build(:message, sender: buyer) }
  let(:account_id) { buyer.id }

  api 'message' do
    post '/admin/api/accounts/:account_id/messages.:format', action: :create do
      parameter :body, 'Message Body'
      parameter :subject, 'Message Subject'
      let(:body) { 'This is some text' }
      let(:subject) { 'custom subject' }

      after do
        serializable.body.should == body
        serializable.subject.should_not == subject
      end
    end
  end

  json(:resource) do
    let(:root) { 'message' }
    it { should have_properties('id', 'body', 'subject', 'state').from(resource) }
  end

  json(:collection) do
    let(:root) { 'messages' }
    it { should be_an(Array) }
  end

  xml(:resource) do
    before { resource.save! }
    it('has a root') { should have_tag('message') }
    it { should be_equivalent_to(example) }

    let(:sample) do
      %{
      <message>
        <id>#{resource.id}</id>
        <body>#{resource.body}</body>
        <subject>#{resource.subject}</subject>
        <state>#{resource.state}</state>
      </message>
      }
    end

  end
end

__END__

admin_api_account_messages POST   /admin/api/accounts/:account_id/messages(.:format) admin/api/messages#create {:format=>"xml"}

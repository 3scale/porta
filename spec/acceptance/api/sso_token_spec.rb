require 'spec_helper'

resource "SSOToken" do

  before { Timecop.freeze }
  after { Timecop.return }

  let(:user_id) { provider.managed_users.first.id }
  let(:expires_in) { 60 }

  let(:sso_token) do
    SSOToken.new(user_id: user_id, expires_in: expires_in)
  end


  api 'sso token' do
    before do
      expect(SSOToken).to receive(:new).with('user_id' => user_id.to_s, 'expires_in' => expires_in.to_s)
                              .and_return(sso_token)

    end
    let(:resource) { sso_token.dup.tap{ |s| s.account = provider } }

    post '/admin/api/sso_tokens.:format', action: :create do
      let(:serializable) { resource }

      parameter :user_id, "User ID"
      parameter :expires_in, "Expires in seconds"
    end
  end

  json(:resource) do
    let(:resource) { sso_token.dup.tap{ |s| s.account = provider } }

    let(:root) { 'sso_token' }
    it { should include('sso_url') }
  end

end

__END__

admin_api_sso_tokens POST   /admin/api/sso_tokens(.:format) admin/api/sso_tokens#create {:format=>"xml"}

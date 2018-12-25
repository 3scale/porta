# frozen_string_literal: true

require 'spec_helper'

resource 'Signup::ResultWithAccessToken' do
  let(:resource) do
    account = FactoryBot.build(:provider_account)
    user = FactoryBot.build(:user, account: account)
    result = ::Signup::ResultWithAccessToken.new(user: user, account: account)
    result.save
    result
  end
  let(:expected_account_properties) { %w[id created_at updated_at admin_domain domain from_email state] }
  let(:expected_access_token_properties) { %w[id name scopes permission value] }

  json(:resource) do
    let(:root) { 'signup' }

    it do
      subject.fetch('account').should have_properties(expected_account_properties).from(resource.account)
      subject.fetch('access_token').should have_properties(expected_access_token_properties).from(resource.access_token)
    end

    it { should_not include('errors') }

    xit 'renders errors correctly' do
      # TODO: bug in rendering errors from specs
      resource.user.update_attributes(email: '')
      subject.fetch('errors').should include('user' => ['Email should look like an email address'])
    end
  end

  xml(:resource) do
    it('has root') { should have_tag('signup') }

    context 'account' do
      subject { xml.root.xpath('./account') }
      it { should have_tags(expected_account_properties).from(resource.account) }
    end

    context 'access_token' do
      subject { xml.root.xpath('./access_token') }
      it { should have_tags(expected_access_token_properties).from(resource.access_token) }
    end

    it { should_not have_tag('errors') }

    xit 'renders errors correctly' do
      # TODO: bug in rendering errors from specs
      resource.user.update_attributes(email: '')
      subject { xml.root.xpath('./errors') }
      should have_tag('user', :text => ['Email should look like an email address'])
    end
  end
end

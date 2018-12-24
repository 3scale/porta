# frozen_string_literal: true

require 'spec_helper'

resource 'AuthenticationProvider' do

  let(:authentication_provider) do
    FactoryBot.build_stubbed(:authentication_provider,
                      token_url: 'http://token_url', user_info_url: 'http://user_info_url',
                      authorize_url: 'http://authorize_url', updated_at: Time.now)
  end
  let(:resource) do
    fake_request = OpenStruct.new(host: authentication_provider.account.domain, scheme: 'https', query_parameters: {})
    OauthFlowPresenter.new(authentication_provider, fake_request)
  end
  let(:domain) { resource.account.domain }
  let(:system_name) { resource.system_name }
  let(:expected_properties) do
    %w[
      id kind account_type name system_name client_id client_secret trust_email published site account_id
      token_url user_info_url authorize_url skip_ssl_certificate_verification automatically_approve_accounts
      branding_state username_key identifier_key created_at updated_at
    ]
  end

  json(:resource) do
    let(:root) { 'authentication_provider' }

    it { should have_properties(expected_properties).from(authentication_provider) }

    context 'auth0' do
      let(:authentication_provider) { FactoryBot.build_stubbed(:authentication_provider, kind: 'auth0') }
      it do
        expected_callback = "https://#{domain}/auth/#{system_name}/callback, https://#{domain}/auth/invitations/auth0/#{system_name}/callback"
        should include('callback_url' => expected_callback)
      end
    end

    context 'redhat_customer_portal' do
      let(:authentication_provider) { FactoryBot.build_stubbed(:authentication_provider, kind: 'red_hat_customer_portal') }
      it do
        expected_callback = "https://#{domain}/auth/#{system_name}/callback"
        should include('callback_url' => expected_callback)
      end
    end

    context 'github' do
      let(:authentication_provider) { FactoryBot.build_stubbed(:authentication_provider, kind: 'github') }
      it do
        authentication_provider.stubs(:callback_account).returns(master_account)
        should_not include('callback_url')
      end
    end
  end

  json(:collection) do
    let(:root) { 'authentication_providers' }
    context do
      let(:collection) { [resource, resource] }
      it 'contains the authentication providers data by its representer' do
        subject.each do |subject_authentication_provider|
          subject_authentication_provider.should include('authentication_provider')
          subject_authentication_provider.fetch('authentication_provider').should have_properties(expected_properties).from(authentication_provider)
        end
      end
    end
  end

  xml(:resource) do
    it('has root') { should have_tag('authentication_provider') }

    context 'root' do
      subject { xml.root }
      it { should have_tags(expected_properties).from(authentication_provider) }
    end

    context 'auth0' do
      let(:authentication_provider) { FactoryBot.build_stubbed(:authentication_provider, kind: 'auth0') }

      it do
        expected_callback = "https://#{domain}/auth/#{system_name}/callback, https://#{domain}/auth/invitations/auth0/#{system_name}/callback"
        xml.root.should have_tag('callback_url', :text => expected_callback)
      end
    end

    context 'redhat_customer_portal' do
      let(:authentication_provider) { FactoryBot.build_stubbed(:authentication_provider, kind: 'red_hat_customer_portal') }
      subject { xml.root }
      it do
        expected_callback = "https://#{domain}/auth/#{system_name}/callback"
        should have_tag('callback_url', :text => expected_callback)
      end
    end

    context 'github' do
      let(:authentication_provider) { FactoryBot.build_stubbed(:authentication_provider, kind: 'github') }
      subject { xml.root }
      it do
        authentication_provider.stubs(:callback_account).returns(master_account)
        should_not have_tag('callback_url')
      end
    end
  end

  xml(:collection) do
    context do
      let(:collection) { [resource, resource] }
      it 'contains the authentication providers data by its representer' do
        subject { xml.root }
        xml_authentication_providers = subject.xpath('./authentication_providers//authentication_provider')
        assert_equal collection.size, xml_authentication_providers.size
        xml_authentication_providers.each do |subject_authentication_provider|
          subject_authentication_provider.should have_tags(expected_properties).from(authentication_provider)
        end
      end
    end
  end
end

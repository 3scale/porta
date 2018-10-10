# frozen_string_literal: true

require 'spec_helper'

resource "MemberPermission" do

  let(:user) { Factory(:user, account: provider) }
  let(:resource) { user.member_permissions }
  let(:serialized) { representer.send(serialization_format, user: user) }

  before do
    provider.settings.allow_multiple_users!
  end

  shared_context "allowed sections are configured" do
    before do
      user.member_permissions.create(admin_section: :partners)
    end
  end

  shared_context "allowed services are configured" do
    before do
      expect(user.account).to receive(:service_ids).and_return([1])
      user.member_permissions.create(admin_section: :services, service_ids: [1])
    end
  end

  shared_context "all services disabled" do
    before do
      user.member_permission_service_ids = "[]"
    end
  end

  shared_context "all services enabled" do
    before do
      user.member_permission_service_ids = nil
    end
  end

  api 'user permissions' do
    let(:user_id) { user.id }
    let(:resource_representer) { 'MemberPermissionsRepresenter' }

    before do
      expect(resource).to receive(:save!).and_return(resource)
    end

    get '/admin/api/users/:user_id/permissions.:format', action: :show

    put '/admin/api/users/:user_id/permissions.:format', action: :update do
      include_context 'allowed sections are configured'
      before do
        expect(resource).to receive(:created_at).and_return(user.created_at)
        expect(resource).to receive(:updated_at).and_return(user.updated_at)
      end

      parameter :allowed_sections, 'Allowed sections'
      let(:allowed_sections) { %w[monitoring finance] }
    end
  end

  json(:resource) do
    let(:root) { 'permissions' }
    let(:representer) { MemberPermissionsRepresenter.format(:json).prepare(serializable) }

    it { should have_properties('user_id', 'role') }

    context 'if allowed sections are configured' do
      include_context 'allowed sections are configured'
      it { should include('allowed_sections' => ['partners'] ) }
    end

    context 'if allowed services are configured' do
      include_context 'allowed services are configured'
      it { should include('allowed_service_ids' => [1] ) }
    end

    context 'if all services are enabled' do
      include_context 'all services enabled'

      it { should include('allowed_service_ids' => nil ) }
    end

    context 'if all services are disabled' do
      include_context 'all services disabled'

      it { should include('allowed_service_ids' => [] ) }
    end

    it { should have_links('user') }
  end


  xml(:resource) do
    let(:representer) { MemberPermissionsRepresenter.format(:xml).prepare(serializable) }

    it('has root') { should have_tag('permissions') }

    context "root" do
      subject { xml.root }
      it { should have_tag('user_id') }
      it { should have_tag('role') }

      context 'if allowed sections are configured' do
        include_context 'allowed sections are configured'
        it 'should have allowed sections tag' do
          should have_tag('allowed_sections') {
            with_tag 'allowed_section', :text => 'partners'
          }
        end
      end

      context 'if allowed services are configured' do
        include_context 'allowed services are configured'
        it 'should have allowed service ids' do
          should have_tag('allowed_service_ids') {
            with_tag 'allowed_service_id', :text => '1'
          }
        end
      end

      context 'if all services are enabled' do
        include_context 'all services enabled'

        it { should_not have_tag('allowed_service_ids') }
      end

      context 'if all services are disabled' do
        include_context 'all services disabled'

        it { should have_tag('allowed_service_ids', :text => "") }
      end
    end
  end

end

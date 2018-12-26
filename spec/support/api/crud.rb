shared_examples 'CRUD #create', action: :create do
  include_context "provider api"
  include_context "resource"

  let(:serializable) { resource.class.unscoped.last }

  request "Create #{model}", status: 201
end

shared_context 'CRUD resource save' do
  before do
    resource.save! unless example.metadata[:skip_resource_save]
  end
end

shared_examples 'CRUD #show', action: :show do
  include_context "provider api"
  include_context "resource"
  include_context 'CRUD resource save'

  request "Get #{model}"
end

shared_examples 'CRUD #update', action: :update do
  include_context "provider api"
  include_context "resource"
  include_context 'CRUD resource save'

  request "Update #{model}" do
    updatable_resource.reload
    updatable_resource.updated_at.should_not == updatable_resource.created_at
  end
end

shared_examples 'CRUD #index', action: :index do
  include_context "provider api"
  include_context "collection"
  include_context 'CRUD resource save'

  request "List #{models}"
end

shared_examples 'CRUD #destroy', action: :destroy do
  include_context "provider api"
  include_context "resource"
  include_context 'CRUD resource save'

  request "Destroy #{model}", body: false
end

shared_examples 'CRUD #default', action: :default do
  include_context "provider api"
  include_context "resource"
  include_context 'CRUD resource save'

  request "Mark #{model} as default" do
    resource.reload
    default.should == resource
  end
end

shared_examples 'CRUD #activate', action: :activate do
  include_context "resource"
  let(:desired_state) { 'active' }
  include_context 'CRUD resource save'

  request "Activate #{model}" do
    resource.reload.state == desired_state
  end
end

shared_examples 'CRUD #suspend',  action: :suspend do
  include_context "resource"
  let(:desired_state) { 'suspended' }
  include_context 'CRUD resource save'

  request "Suspend #{model}" do
    resource.reload.state == desired_state
  end
end

shared_examples 'CRUD #unsuspend', action: :unsuspend do
  include_context "resource"
  let(:desired_state) { 'active' }
  include_context 'CRUD resource save'

  request "Unsuspend #{model}" do
    resource.reload.state == desired_state
  end
end

shared_examples 'CRUD #admin', action: :admin do
  include_context "resource"
  include_context 'CRUD resource save'

  request "Make #{model} admin" do
    resource.reload.role == :admin
  end
end

shared_examples 'CRUD', action: :member do
  include_context "resource"
  include_context 'CRUD resource save'

  request "Make #{model} member" do
    resource.reload.role == :member
  end
end

shared_examples 'CRUD', action: true do
  include_context "provider api"
end

shared_examples action: :create do
  include_context "provider api"
  include_context "resource"

  let(:serializable) { resource.class.unscoped.last }

  request "Create #{model}", status: 201
end

shared_examples action: :show do
  include_context "provider api"
  include_context "resource"

  before { resource.save! }

  request "Get #{model}"
end

shared_examples action: :update do
  include_context "provider api"
  include_context "resource"

  before { resource.save! }

  request "Update #{model}" do
    resource.reload
    resource.updated_at.should_not == resource.created_at
  end
end

shared_examples action: :index do
  include_context "provider api"
  include_context "collection"

  before { resource.save! }

  request "List #{models}"
end

shared_examples action: :destroy do
  include_context "provider api"
  include_context "resource"

  before { resource.save! }

  request "Destroy #{model}", body: false
end

shared_examples action: :default do
  include_context "provider api"
  include_context "resource"

  before { resource.save! }

  request "Mark #{model} as default" do
    resource.reload
    default.should == resource
  end
end

shared_examples action: :activate do
  include_context "resource"
  let(:desired_state) { 'active' }

  before { resource.save! }

  request "Activate #{model}" do
    resource.reload.state == desired_state
  end
end

shared_examples action: :suspend do
  include_context "resource"
  let(:desired_state) { 'suspended' }

  before { resource.save! }

  request "Suspend #{model}" do
    resource.reload.state == desired_state
  end
end

shared_examples action: :unsuspend do
  include_context "resource"
  let(:desired_state) { 'active' }

  before { resource.save! }

  request "Unsuspend #{model}" do
    resource.reload.state == desired_state
  end
end

shared_examples action: :admin do
  include_context "resource"

  before { resource.save! }

  request "Make #{model} admin" do
    resource.reload.role == :admin
  end
end

shared_examples action: :member do
  include_context "resource"

  before { resource.save! }

  request "Make #{model} member" do
    resource.reload.role == :member
  end
end

shared_examples action: true do
  include_context "provider api"
end

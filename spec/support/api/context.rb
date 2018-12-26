shared_context "api", api: true do
  include_context "provider api"
  include_context "naming helpers"
  include_context "representers"
  include_context "serialization format"

  before { Timecop.scale(3600) }
  after { Timecop.scale(1) }
end

shared_context "representers" do
  unless method_defined?(:model_name)
    let(:model_name) { self.class.model_name }
  end

  # don't define representers if they were already defined in parent scope
  unless method_defined?(:resource_representer)
    let(:resource_representer) { (model_name.to_s.underscore + "_representer").camelize }
  end

  unless method_defined?(:collection_representer)
    let(:collection_representer) { (model_name.to_s.pluralize.underscore + "_representer").camelize }
  end
end

shared_context "provider api", provider: true do
  let(:master) { provider && master_account }
  let(:provider) { FactoryBot.create(:provider_account, self_domain: 'example.org') }
  let(:provider_key) { provider.provider_key }

  parameter :provider_key, 'Provider Key'
end

shared_context "serialization format", serialization: true do
  let(:serialization_format) { "to_#{format}" }
  let(:serializable) { nil }
  unless method_defined?(:serialized)
    let(:serialized) do
      raise "representer can't be a mock!" if representer.is_a?(RSpec::Mocks::Double)
      representer.send(serialization_format)
    end
  end
end

shared_context "naming helpers" do
  let(:model) { resource.class }
  let(:name) { model.model_name.human }
end

shared_context "resource", resource: true do
  let(:serializable) { resource }
  let(:representer) { resource_representer.constantize.format(format).prepare(serializable) }
  let(:updatable_resource) { resource } unless method_defined?(:updatable_resource)

  let(:id) { resource.id }
end

shared_context "collection", collection: true do
  # do something
  include_context "resource"

  unless method_defined?(:collection)
    let(:collection) { [resource] }
  end

  let(:serializable) { collection }
  let(:representer) { collection_representer.constantize.format(format).prepare(serializable) }
end

shared_context "json", json: true do
  before { resource.save! if resource.respond_to?(:save!) }

  let(:format) { :json }
  let(:json) { JSON.parse(serialized) }

  subject { json[root] }

  it("should have root") { expect(json).to have_key(root) }
end

shared_context "xml", xml: true do
  let(:format) { :xml }
  subject(:xml) { Nokogiri::XML(serialized) }
  let(:example) { Nokogiri::XML(sample) }
end

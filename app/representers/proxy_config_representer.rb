module ProxyConfigRepresenter
  include ThreeScale::JSONRepresenter

  wraps_resource

  property :id
  property :version
  property :environment
  property :content

  def content
    ::JSON.parse(super)
  end
end

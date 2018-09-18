module MessageRepresenter
  include ThreeScale::JSONRepresenter

  wraps_resource

  property :id
  property :body
  property :subject
  property :state

  property :created_at
  property :updated_at
end

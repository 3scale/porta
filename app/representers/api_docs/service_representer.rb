module ApiDocs::ServiceRepresenter
  include ThreeScale::JSONRepresenter

  wraps_resource :api_doc

  property :id
  property :system_name
  property :name
  property :description
  property :published
  property :skip_swagger_validations
  property :body
  property :service_id

  property :created_at
  property :updated_at
end

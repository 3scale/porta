module ApiDocs::ServicesRepresenter
  include ThreeScale::JSONRepresenter

  wraps_collection :api_docs

  items extend: ApiDocs::ServiceRepresenter
end

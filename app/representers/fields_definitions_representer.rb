# frozen_string_literal: true

class FieldsDefinitionsRepresenter < ThreeScale::CollectionRepresenter
  include Roar::JSON::Collection

  wraps_resource :fields_definitions

  items extend: FieldsDefinitionRepresenter
end

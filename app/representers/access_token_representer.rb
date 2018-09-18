# frozen_string_literal: true

class AccessTokenRepresenter < ThreeScale::Representer
  include ThreeScale::JSONRepresenter
  include Roar::XML

  wraps_resource :access_token

  property :id

  property :name
  property :scopes
  property :permission
  property :value, if: :show_value?
end

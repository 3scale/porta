# frozen_string_literal: true

class SignupResultWithAccessTokenRepresenter < ThreeScale::Representer
  include ThreeScale::JSONRepresenter
  include Roar::XML

  wraps_resource :signup

  property :account, decorator: AccountRepresenter, wrap: false
  property :errors, if: ->(*) { errors.any? }
  property :access_token, decorator: AccessTokenRepresenter, wrap: false
end

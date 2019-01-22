# frozen_string_literal: true

module AccessTokensRepresenter
  include ThreeScale::JSONRepresenter

  wraps_collection :access_tokens

  items extend: AccessTokenRepresenter
end

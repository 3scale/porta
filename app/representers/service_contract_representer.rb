# frozen_string_literal: true

module ServiceContractRepresenter
  include ThreeScale::JSONRepresenter
  wraps_resource

  property :id
  property :plan_id
end
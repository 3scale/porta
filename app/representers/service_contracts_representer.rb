# frozen_string_literal: true

module ServiceContractsRepresenter
  include ThreeScale::JSONRepresenter
  wraps_collection :service_contracts
end

# frozen_string_literal: true

module ServiceContractsRepresenter
  class JSON < AuthenticationProvidersRepresenter
    include ThreeScale::JSONRepresenter
    # include Roar::JSON::Collection
    wraps_resource :service_contracts
    items extend: ServiceContractRepresenter
  end

  class XML < AuthenticationProvidersRepresenter
    include Roar::XML
    wraps_resource :service_contracts
    items extend: ServiceContractRepresenter
  end
end

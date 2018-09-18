# frozen_string_literal: true

class AuthenticationProvidersRepresenter < ThreeScale::CollectionRepresenter
  class JSON < AuthenticationProvidersRepresenter
    include Roar::JSON::Collection
    wraps_resource :authentication_providers
    items extend: AuthenticationProviderRepresenter
  end

  class XML < AuthenticationProvidersRepresenter
    include Roar::XML
    wraps_resource :authentication_providers
    items extend: AuthenticationProviderRepresenter
  end
end

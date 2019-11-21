# frozen_string_literal: true

module Signup
  class MasterDomainsBuilder < Signup::DomainsBuilder
    def generate
      new_subdomain = current_subdomain.presence || generate_subdomain
      Signup::Domains.new(subdomain: new_subdomain, self_subdomain: new_subdomain)
    end
  end
end

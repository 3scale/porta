# frozen_string_literal: true

class Signup::MasterDomainsBuilder < Signup::DomainsBuilder
  def generate
    if current_subdomain.present?
      Signup::Domains.new(subdomain: current_subdomain, self_subdomain: current_subdomain)
    else
      new_subdomain = generate_subdomain
      Signup::Domains.new(subdomain: "#{new_subdomain}-admin", self_subdomain: "#{new_subdomain}-admin")
    end
  end
end

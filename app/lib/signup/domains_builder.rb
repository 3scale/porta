# frozen_string_literal: true

class Signup::DomainsBuilder
  def initialize(current_subdomain: nil, org_name: nil, invalid_subdomain_condition: ->(_subdomain_to_validate) { false })
    raise ArgumentError,'organization name or the current subdomain must be provided in order to generate domains' if org_name.blank? && current_subdomain.blank?
    @current_subdomain = current_subdomain
    @org_name = org_name
    @invalid_subdomain_condition = invalid_subdomain_condition
  end

  def generate
    subdomain = current_subdomain || generate_subdomain
    Signup::Domains.new(subdomain: subdomain, self_subdomain: "#{subdomain}-admin")
  end

  def generate_subdomain
    result = org_name.to_s.parameterize

    while result.present? && invalid_subdomain_condition.call(subdomain: result)
      base, sequence = result.match(/\A(.*?)(?:\-(\d+))?\z/).to_a[1, 2]
      result = base + '-' + ((sequence || 1).to_i + 1).to_s
    end

    result
  end

  private

  attr_reader :current_subdomain, :org_name, :invalid_subdomain_condition
end

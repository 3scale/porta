# frozen_string_literal: true

module MethodRepresenter
  include ThreeScale::JSONRepresenter

  wraps_resource :method

  property :id
  property :name
  property :system_name
  property :friendly_name
  property :description

  property :created_at
  property :updated_at

  link :parent do
    polymorphic_url([:admin, :api, owner, parent])
  end

  link :self do
    polymorphic_url([:admin, :api, owner, parent, :methods], id: id)
  end

  def system_name
    backend_api_metric? ? attributes['system_name'] : super
  end
end

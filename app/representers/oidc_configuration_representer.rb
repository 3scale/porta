# frozen_string_literal: true

module OIDCConfigurationRepresenter
  include ThreeScale::JSONRepresenter

  property :id
  OIDCConfiguration::Config::ATTRIBUTES.each do |attr|
    property attr
  end
end

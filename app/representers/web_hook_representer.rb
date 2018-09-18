module WebHookRepresenter
  include ThreeScale::JSONRepresenter

  wraps_resource 'webhook'

  property :url
  property :active
  property :provider_actions

  WebHook.switchable_attributes.each do |attr_name|
    property attr_name
  end
end

module FeatureRepresenter
  include ThreeScale::JSONRepresenter

  wraps_resource

  property :id
  property :name
  property :system_name
  property :scope
  property :visible
  property :description

  property :created_at
  property :updated_at

  def scope
    super.underscore
  end

  link :self do
    case featurable_type
    when 'Service'
        admin_api_service_feature_url(featurable_id, id)
    when 'Account'
        admin_api_feature_url(id)
    end if id
  end

  link :service do
    if featurable_type == "Service" && featurable_id
      admin_api_services_url(featurable_id)
    end
  end
end

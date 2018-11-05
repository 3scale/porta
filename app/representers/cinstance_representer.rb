# TODO:
#   * check if json output has the same data as xml
module CinstanceRepresenter
  include ThreeScale::JSONRepresenter
  include FieldsRepresenter
  include ExtraFieldsRepresenter

  wraps_resource :application

  property :id

  property :state
  property :enabled?, as: :enabled
  property :end_user_required

  property :created_at
  property :updated_at
  property :service_id
  property :plan_id
  property :user_account_id, as: :account_id
  property :first_traffic_at, render_nil: true
  property :first_daily_traffic_at, render_nil: true

  with_options(if: ->(*) { backend_version.v1? }, render_nil: true) do |v1|
    v1.property :user_key
    v1.property :provider_verification_key
  end

  with_options(if: ->(*) { backend_version.v2? || backend_version.oauth? }, render_nil: true) do |v2|
    v2.property :application_id
  end

  with_options(if: ->(*) { backend_version.oauth? }, render_nil: true) do |oauth|
    oauth.property :redirect_url
    oauth.property :client_id
    oauth.property :client_secret
  end

  def provider_verification_key
    provider_public_key
  end

  link :self do
    admin_api_account_application_url(user_account_id, id) if user_account_id && id
  end

  link :service do
    admin_api_service_url(service_id)
  end

  link :account do
    admin_api_account_url(user_account_id) if user_account_id
  end

  link :plan do
    admin_api_service_application_plan_url(service_id, plan_id)
  end

  link :keys do
    admin_api_account_application_keys_url(user_account_id, id) if user_account_id && id
  end

  # TODO: show this only if referrer_filters_required?
  link :referrer_filters do
    admin_api_account_application_referrer_filters_url(user_account_id, id) if user_account_id && id
  end

  def client_secret
    keys.first
  end

  def client_id
    application_id
  end

  delegate :id, to: :service, prefix: true
end

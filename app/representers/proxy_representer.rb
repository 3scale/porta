class ProxyRepresenter < ThreeScale::Representer
  wraps_resource :proxy

  property :service_id
  property :endpoint
  property :deployed_at
  property :api_backend, render_nil: true
  property :credentials_location
  property :auth_app_key
  property :auth_app_id
  property :auth_user_key

  property :error_auth_failed
  property :error_auth_missing
  property :error_status_auth_failed

  property  :error_status_auth_failed
  property  :error_headers_auth_failed
  property  :error_status_auth_missing
  property  :error_headers_auth_missing
  property  :error_no_match
  property  :error_status_no_match
  property  :error_headers_no_match
  property  :error_limits_exceeded
  property  :error_status_limits_exceeded
  property  :error_headers_limits_exceeded

  property  :secret_token
  property  :hostname_rewrite
  property  :oauth_login_url
  property  :sandbox_endpoint
  property  :api_test_path
  property  :api_test_success
  property  :policies_config, exec_context: :decorator

  property :created_at
  property :updated_at

  property :deployment_option

  # By sending the lock_version with the update call the record is updated only when matching that version.
  property :lock_version

  property :oidc_issuer_endpoint, if: ->(*) { oidc? }
  property :oidc_issuer_type, if: ->(*) { oidc? }

  property :jwt_claim_with_client_id, if: ->(*) { oidc? }
  property :jwt_claim_with_client_id_type, if: ->(*) { oidc? }

  def policies_config
    represented.policies_config.as_json
  end

  class JSON < ProxyRepresenter
    include Roar::JSON

    link :mapping_rules do
      admin_api_service_proxy_mapping_rules_path(represented.service_id)
    end

    link :self do
      admin_api_service_proxy_path(represented.service_id)
    end

    link :service do
      admin_api_service_path(represented.service_id)
    end
  end

  class XML < ProxyRepresenter
    include Roar::XML
    wraps_resource :proxy
  end
end

class ProxyRuleRepresenter < ThreeScale::Representer
  wraps_resource :mapping_rule

  property :id
  property :metric_id
  property :pattern
  property :http_method
  property :delta
  property :position
  property :last

  with_options(if: ->(*) { !backend_api_owner? && proxy.service.using_proxy_pro? }, render_nil: true) do |proxy_pro|
    proxy_pro.property :redirect_url
  end

  property :created_at
  property :updated_at

  class JSON < ProxyRuleRepresenter
    include Roar::JSON
    include Roar::Hypermedia

    delegate :backend_api_owner?, :owner, :owner_id, :id, to: :represented
    delegate :service_id, to: :owner

    link :self do
      if backend_api_owner?
        admin_api_backend_api_mapping_rule_path(owner_id, id)
      else
        admin_api_service_proxy_mapping_rule_path(service_id, id)
      end
    end

    link :backend_api do
      admin_api_backend_api_url(owner_id) if backend_api_owner?
    end

    link :service do
      admin_api_service_path(service_id) unless backend_api_owner?
    end

    link :proxy do
      admin_api_service_proxy_path(service_id) unless backend_api_owner?
    end
  end

  class XML < ProxyRuleRepresenter
    include Roar::XML
    wraps_resource :mapping_rule # including Roar::XML resets the wrap
  end
end

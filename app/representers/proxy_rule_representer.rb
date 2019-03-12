class ProxyRuleRepresenter < ThreeScale::Representer
  wraps_resource :mapping_rule

  property :id
  property :metric_id
  property :pattern
  property :http_method
  property :delta
  property :position
  property :last

  with_options(if: ->(*) { proxy.service.using_proxy_pro? }, render_nil: true) do |proxy_pro|
    proxy_pro.property :redirect_url
  end

  property :created_at
  property :updated_at

  class JSON < ProxyRuleRepresenter
    include Roar::JSON
    include Roar::Hypermedia

    link :self do
      admin_api_service_proxy_mapping_rule_path(represented.proxy.service_id, represented.id)
    end

    link :service do
      admin_api_service_path(represented.proxy.service_id)
    end

    link :proxy do
      admin_api_service_proxy_path(represented.proxy.service_id)
    end
  end

  class XML < ProxyRuleRepresenter
    include Roar::XML
    wraps_resource :mapping_rule # including Roar::XML resets the wrap
  end
end

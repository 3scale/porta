class ProxyRulesRepresenter < ThreeScale::CollectionRepresenter
  wraps_resource :mapping_rules

  class JSON < ProxyRulesRepresenter
    include Roar::JSON::Collection
    items extend: ProxyRuleRepresenter::JSON, class: ProxyRule
  end

  class XML < ProxyRulesRepresenter
    include Roar::XML
    wraps_resource :mapping_rules # because including Roar::XML resets the wrap
    items extend: ProxyRuleRepresenter::XML, class: ProxyRule
  end
end

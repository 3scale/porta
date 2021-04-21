# frozen_string_literal: true

module ProxyRulesHelper
  def new_mapping_rule_metrics_data(owner)
    {
      isProxyProEnabled: owner.try(:using_proxy_pro?),
      topLevelMetrics: owner.metrics.top_level.decorate.map(&:new_mapping_rule_data),
      methods: owner.method_metrics.decorate.map(&:new_mapping_rule_data)
    }.to_json
  end

  def proxy_rule_path_for(proxy_rule, edit: false)
    owner = proxy_rule.owner
    member_name = case owner
                  when Proxy
                    :proxy_rule
                  when BackendApi
                    :mapping_rule
                  end
    collection = proxy_rules_collection_base_path_for(owner) + [member_name]
    public_send (edit ? :edit_polymorphic_path : :polymorphic_path), collection, id: proxy_rule
  end

  def proxy_rules_path_for(owner)
    collection_name = case owner
                      when Proxy
                        :proxy_rules
                      when BackendApi
                        :mapping_rules
                      end
    collection = proxy_rules_collection_base_path_for(owner) + [collection_name]
    polymorphic_path(collection)
  end

  protected

  def proxy_rules_collection_base_path_for(owner)
    case owner
    when Proxy
      [:admin, owner.service]
    when BackendApi
      [:provider, :admin, owner]
    end
  end
end

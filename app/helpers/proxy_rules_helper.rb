module ProxyRulesHelper
  def proxy_rule_path_for(proxy_rule, edit: false)
    owner = proxy_rule.owner
    collection = case owner
                 when Proxy
                   [:admin, owner.service, :proxy_rule]
                 when BackendApi
                   [:provider, :admin, owner, :mapping_rule]
                 end
    public_send (edit ? :edit_polymorphic_path : :polymorphic_path), collection, id: proxy_rule
  end
end

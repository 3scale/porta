# frozen_string_literal: true

module Api::MappingRulesHelper
  def link_to_mapping_rules(service:)
    path, data = if current_account.independent_mapping_rules_enabled?
                   [admin_service_proxy_rules_path(service), {}]
                 else
                   [edit_admin_service_integration_path(service, anchor: 'mapping-rules'), { behavior: 'open-mapping-rules' }]
                 end

    link_to 'Mapping Rules', path, data: data
  end
end

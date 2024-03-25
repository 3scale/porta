# frozen_string_literal: true

# After they replaced Transform with ParameterType, it's no longer possible to transform data tables.
# Create helper methods instead and use them directly inside step definitions.
# Ref: https://stackoverflow.com/questions/55944335/using-parametertype-with-table-data
# Original transformers: https://github.com/3scale/porta/blob/a5d6622d5a56bbda401f7d95e09b0ab19d05adba/features/support/transforms.rb#L185-L202

module DataTableTransforms
  def transform_backend_apis_table(table)
    parameterize_headers(table, 'System name' => 'system_name',
                                'Private Base URL' => 'private_endpoint')
    table
  end

  def transform_plan_features_table(table)
    parameterize_headers(table)
    table.map_column!(:enabled, false) { |enabled| enabled.casecmp?('true') }
    table
  end

  def transform_alerts_table(table)
    parameterize_headers(table)
    table.map_column!(:application) { |app| Cinstance.find_by!(name: app) }
    table
  end

  def transform_applications_table(table)
    parameterize_headers(table, 'Product' => 'service',
                                'Buyer' => 'user_account')
    table.map_column!(:user_account, false) { |buyer| Account.buyers.find_by!(org_name: buyer) }
    table.map_column!(:service, false) { |service| Service.find_by!(name: service) }
    table.map_column!(:plan, false) { |plan| ApplicationPlan.find_by!(name: plan) }
    table
  end

  def transform_plans_table(plan_type, table)
    parameterize_headers(table, 'Product' => 'issuer',
                                'Requires approval' => 'approval_required',
                                'Trial period' => 'trial_period_days')

    table.map_column!(:cost_per_month, false, &:to_f)
    table.map_column!(:setup_fee, false, &:to_f)
    table.map_column!(:approval_required, false) { |required| required.casecmp?('true') }
    table.map_column!(:default, false) { |default| default.casecmp?('true') }
    table.map_column!(:state, false, &:downcase)
    table.map_column!(:issuer, true) do |name|
      if plan_type == 'account_plan'
        Account.find_by!(org_name: name)
      else
        Service.find_by!(name: name)
      end
    end
    table
  end

  def transform_usage_limits_table(table, plan)
    parameterize_headers(table)
    table.map_column!(:metric) { |metric| plan.issuer.metrics.find_by!(friendly_name: metric) }
    table.map_column!(:max_value, &:to_i)
    table
  end

  def transform_table(table)
    parameterize_headers(table)
    table
  end

  protected

  def parameterize_headers(table, mappings = {})
    table.map_headers! do |header|
      mapped = mappings[header].presence || header
      mapped.parameterize(separator: '_', preserve_case: false).to_s
    end
  end
end

World(DataTableTransforms)

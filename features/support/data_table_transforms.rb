# frozen_string_literal: true

# After they replaced Transform with ParameterType, it's no longer possible to transform data tables.
# Create helper methods instead and use them directly inside step definitions.
# Ref: https://stackoverflow.com/questions/55944335/using-parametertype-with-table-data
# Original transformers: https://github.com/3scale/porta/blob/a5d6622d5a56bbda401f7d95e09b0ab19d05adba/features/support/transforms.rb#L185-L202

module DataTableTransforms
  def transform_buyer_subscriptions_table(table, provider)
    table.map_column(:plans) { |plans| plans.from_sentence.map { |plan| Plan.find_by!(name: plan) } }
      .map_column(:name) { |name| FactoryBot.create(:buyer_account, provider_account: provider, org_name: name) }
      .map_headers(&:to_sym)
  end

  def transform_applications_table(table)
    parameterize_headers(table)
      .map_column(:buyer) { |buyer| Account.buyers.find_by!(org_name: buyer) }
      .map_column(:plan) { |plan| ApplicationPlan.find_by!(name: plan) }
  end

  def transform_application_plans_table(table)
    parameterize_headers(table)
      .map_column(:cost_per_month, &:to_f)
      .map_column(:setup_fee, &:to_f)
  end

  def transform_table(table)
    parameterize_headers(table)
  end

  protected

  def parameterize_headers(table)
    table.map_headers { |header| header.parameterize.underscore.downcase.to_s }
  end

  def symbolize_headers(table)
    table.map_headers { |header| header.parameterize.underscore.downcase.to_sym }
  end
end

World(DataTableTransforms)

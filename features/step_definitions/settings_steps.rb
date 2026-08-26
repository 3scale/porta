# frozen_string_literal: true

Given "{provider} has {string} {enabled}" do |account, toggle, enabled|
  account.settings.update_attribute("#{underscore_spaces(toggle)}_enabled", enabled)
end

Given "{provider} has the following setting(s):" do |account, table|
  attributes = table.rows_hash
  attributes.transform_keys! { |key| underscore_spaces(key) }

  account.settings.update!(attributes)
end

Given "{provider} has {count} account plan(s)" do |provider, count|
  current_size = provider.account_plans.size
  if count > current_size
    FactoryBot.create_list(:account_plan, count - current_size, provider: provider)
  else
    keep_ids = provider.account_plans.take(count).pluck(:id)
    provider.account_plans.where.not(id: keep_ids).destroy_all
  end
end

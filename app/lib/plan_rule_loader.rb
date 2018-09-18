# frozen_string_literal: true

module PlanRuleLoader
  DEFAULT_RULES = {
    enterprise: {
      'rank' => 27,
      'limits' => {'max_users' => nil, 'max_services' => nil},
      'switches' => %w[
        finance
        multiple_applications
        branding
        require_cc_on_signup
        account_plans
        multiple_users
        groups
        end_users
        multiple_services
        service_plans
        skip_email_engagement_footer
        web_hooks
        iam_tools
      ],
      'metadata' => { 'cannot_automatically_be_upgraded_to' => true }
    }
  }.freeze

  module_function

  def load_config
    config = (ThreeScale.config.plan_rules || {}).reverse_merge DEFAULT_RULES
    sorted_config = sort_by_rank(config)
    convert_to_hash_with_plan_rule_objects sorted_config
  end

  def sort_by_rank(yaml)
    yaml.sort_by { |_, attributes| Integer(attributes['rank']) }
  end

  def convert_to_hash_with_plan_rule_objects(config)
    config.each_with_object({}) do |(key, attributes), collection|
      system_name = key.to_sym
      collection[system_name] = PlanRule.new(system_name: system_name, **attributes.deep_symbolize_keys)
    end
  end
end

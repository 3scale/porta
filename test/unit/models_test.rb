# frozen_string_literal: true

require 'test_helper'

class ModelsTest < ActiveSupport::TestCase
  INHERITANCE_COLUMNS = %w[type].freeze

  test 'validate length of strings for all models to do not raise an error reaching DB' do
    exceptions = {
      'Account' => %w[credit_card_auth_code credit_card_authorize_net_payment_profile_token credit_card_partial_number],
      'AccountPlan' => %w[issuer_type],
      'Annotation' => %w[annotated_type],
      'ApplicationPlan' => %w[issuer_type],
      'AuthenticationProvider::Auth0' => %w[account_type],
      'AuthenticationProvider::Custom' => %w[account_type],
      'AuthenticationProvider::GitHub' => %w[branding_state account_type],
      'AuthenticationProvider::Keycloak' => %w[account_type],
      'AuthenticationProvider::RedhatCustomerPortal' => %w[account_type],
      'AuthenticationProvider::ServiceDiscoveryProvider' => %w[account_type],
      'AuthenticationProvider' => %w[account_type],
      'CMS::Builtin::LegalTerm' => %w[title content_type],
      'CMS::Builtin::Page' => %w[title content_type],
      'CMS::Builtin::Partial' => %w[title content_type],
      'CMS::Builtin::StaticPage' => %w[title],
      'CMS::Builtin' => %w[title],
      'CMS::EmailTemplate' => %w[content_type],
      'CMS::Partial' => %w[content_type],
      'CMS::Portlet::Base' => %w[content_type],
      'CMS::Portlet' => %w[content_type],
      'DeletedObject' => %w[owner_type object_type],
      'ExternalRssFeedPortlet' => %w[content_type],
      'Feature' => %w[featurable_type scope],
      'FeaturesPlan' => %w[plan_type],
      'FieldsDefinition' => %w[target],
      'Invitation' => %w[token],
      'Invoice' => %w[pdf_file_name pdf_content_type state friendly_id fiscal_code vat_code currency creation_type],
      'LatestForumPostsPortlet' => %w[content_type],
      'LogEntry' => %w[description],
      'Message' => %w[state],
      'Metric' => %w[owner_type],
      'Notification' => %w[event_id],
      'OIDCConfiguration' => %w[oidc_configurable_type],
      'Onboarding' => %w[wizard_state bubble_api_state bubble_metric_state bubble_deployment_state bubble_mapping_state bubble_limit_state],
      'Plan' => %w[issuer_type],
      'PlanMetric' => %w[plan_type],
      'Policy' => %w[identifier],
      'Profile' => %w[logo_file_name logo_content_type state],
      'Proxy' => %w[endpoint sandbox_endpoint],
      'ProxyConfig' => %w[hosts],
      'ProxyRule' => %w[metric_system_name owner_type],
      'ServicePlan' => %w[issuer_type],
      'Settings' => Switches::SWITCHES.map { |switch| "#{switch}_switch" }  << "cms_token",
      'TableOfContentsPortlet' => %w[content_type],
      'UsageLimit' => %w[period plan_type],
      'UserSession' => %w[key user_agent]
    }

    Rails.application.eager_load!
    models = three_scale_db_models - [BackendApi, Service, Proxy, Topic, Forum]

    validate_columns_for = ->(model, options = {}) do
      model_name = model.name
      exception_attributes = exceptions.fetch(model_name, [])
      next if exception_attributes == :all
      exception_attributes.concat INHERITANCE_COLUMNS
      model.columns.each do |column|
        column_name = column.name
        next if column.type != :string || exception_attributes.include?(column_name) || model.ignored_columns.include?(column_name)

        column_sql_type = column.sql_type
        next if column_sql_type.match(/\Acharacter varying\Z/)
        length = column_sql_type.match(/\(([\d]+)\)/)[1].to_i

        object = model.new({column_name => ('a' * (length + 1))}.merge(options), without_protection: true)
        object.valid?

        column_errors = object.errors[column_name].to_sentence
        next if column_errors.match(/is not included in the list/)
        assert_match /too long/, column_errors, "#{model} is not validating the max length of #{length} for string '#{column_name}'"
      end
    end

    models.each do |model|
      validate_columns_for[model]
    end

    validate_columns_for.call(Proxy, service: Service.new(account: Account.new))
    validate_columns_for.call(Service, account: Account.new)
    validate_columns_for.call(BackendApi, account: Account.new)
  end

end

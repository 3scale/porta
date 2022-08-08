# frozen_string_literal: true

require 'test_helper'

class ModelsTest < ActiveSupport::TestCase
  INHERITANCE_COLUMNS = %w[type].freeze

  test 'validate length of strings for all models to do not raise an error reaching DB' do
    exceptions = {
      'Audited::Audit' => :all, 'RailsEventStoreActiveRecord::Event' => :all,
      'ActiveStorage::Attachment' => :all, 'ActiveRecord::SchemaMigration' => :all, 'ActiveStorage::Blob' => :all,
      'System::Database::ConnectionProbe' => :all, 'ActsAsTaggableOn::Tag' => :all, 'ActsAsTaggableOn::Tagging' => :all, 'ApplicationRecord' => :all,
      'FieldsDefinition' => %w[target], 'AuthenticationProvider' => %w[account_type], 'Feature' => %w[featurable_type scope], 'Message' => %w[state],
      'UsageLimit' => %w[period plan_type], 'Policy' => %w[identifier], 'ProxyRule' => %w[metric_system_name], 'ProxyConfig' => %w[hosts],
      'Proxy' => %w[endpoint sandbox_endpoint], 'OIDCConfiguration' => %w[oidc_configurable_type], 'Invitation' => %w[token],
      'Settings' => Switches::SWITCHES.map { |switch| "#{switch}_switch" },
      'Invoice' => %w[pdf_file_name pdf_content_type state friendly_id fiscal_code vat_code currency creation_type], 'DeletedObject' => %w[owner_type object_type],
      'Onboarding' => %w[wizard_state bubble_api_state bubble_metric_state bubble_deployment_state bubble_mapping_state bubble_limit_state],
      'FeaturesPlan' => %w[plan_type], 'LogEntry' => %w[description], 'Notification' => %w[event_id], 'PlanMetric' => %w[plan_type],
      'Profile' => %w[logo_file_name logo_content_type state], 'UserSession' => %w[key user_agent], 'CMS::Partial' => %w[content_type],
      'CMS::EmailTemplate' => %w[content_type], 'CMS::Builtin' => %w[title], 'CMS::Builtin::StaticPage' => %w[title], 'CMS::Builtin::Page' => %w[title content_type],
      'CMS::Builtin::Partial' => %w[title content_type], 'CMS::Portlet' => %w[content_type], 'CMS::Builtin::LegalTerm' => %w[title content_type],
      'CMS::Portlet::Base' => %w[content_type], 'ExternalRssFeedPortlet' => %w[content_type],
      'LatestForumPostsPortlet' => %w[content_type], 'TableOfContentsPortlet' => %w[content_type], 'AuthenticationProvider::GitHub' => %w[branding_state account_type],
      'AuthenticationProvider::Keycloak' => %w[account_type], 'AuthenticationProvider::Auth0' => %w[account_type], 'AuthenticationProvider::Custom' => %w[account_type],
      'AuthenticationProvider::ServiceDiscoveryProvider' => %w[account_type], 'AuthenticationProvider::RedhatCustomerPortal' => %w[account_type],
      'Account' => %w[credit_card_auth_code credit_card_authorize_net_payment_profile_token credit_card_partial_number]
    }

    Rails.application.eager_load!
    models = ActiveRecord::Base.descendants - [BackendApi, Service, Proxy, Topic, Forum]

    validate_columns_for = ->(model, options = {}) do
      model_name = model.name
      next if model_name.blank? || model_name.match(/^.+Test::.+$/)
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

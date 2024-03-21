# frozen_string_literal: true

namespace :database do
  desc 'Check and remove orphaned objects'
  task cleanup_orphans: :environment do
    puts 'Checking and removing orphaned objects...'

    # Tables to exclude from orphaned objects check
    excluded_tables = ['accounts', 'audits', 'categories', 'category_types', 'cms_templates', 'legal_term_acceptances', 'legal_term_bindings',
                      'legal_term_versions', 'proxy_logs', 'schema_migrations', 'service_cubert_infos', 'slugs', 'taggings', 'tags']

    ids = Account.where(provider: true).pluck(:id)
    # Iterate over tables with tenant_id field
    tables = ActiveRecord::Base.connection.tables.select { |t| ActiveRecord::Base.connection.column_exists?(t, 'tenant_id') }

    tables.each do |table|
      next if excluded_tables.include?(table)

      class_name = convert_table_to_class(table)
      orphaned_objects = class_name.where.not(tenant_id: ids)

      if orphaned_objects.exists?
        puts "Found orphaned objects in #{table}:"
        orphaned_objects.each { |obj| puts "- ID: #{obj.id}, Tenant ID: #{obj.tenant_id}" }

        # Uncomment the line below if you want to delete orphaned objects
        # orphaned_objects.destroy_all
      else
        puts "No orphaned objects found in #{table}."
      end
    end
    puts 'Orphaned objects check completed.'
  end

  private

  def convert_table_to_class(table)
    case table
    when 'api_docs_services'
      'ApiDocs::Service'.constantize
    when 'billing_strategies'
      'Finance::BillingStrategy'.constantize
    when 'cms_files'
      'CMS::File'.constantize
    when  'cms_group_sections'
      'CMS::GroupSection'.constantize
    when 'cms_groups'
      'CMS::Group'.constantize
    when 'cms_permissions'
      'CMS::Permission'.constantize
    when 'cms_redirects'
      'CMS::Redirect'.constantize
    when 'cms_sections'
      'CMS::Section'.constantize
    when 'cms_templates_versions'
       'CMS::Template::Version'.constantize 
    when 'cms_legal_term'
      'CMS::LegalTerm'.constantize
    when 'configuration_values'
      'Configuration::Value'.constantize
    when 'event_store_events'
      'EventStore::Event'.constantize
    when 'legal_terms'
      'CMS::LegalTerm'.constantize
    when 'mail_dispatch_rules'
      'MailDispatchRule'.constantize
    when 'notification_preferences'
      'NotificationPreferences'.constantize
    when  'provider_constraints'
      'ProviderConstraints'.constantize
    when 'settings'
      'Settings'.constantize
    else
      table.classify.safe_constantize || table.singularize.camelize.constantize
    end
  end
end

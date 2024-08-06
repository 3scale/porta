# frozen_string_literal: true

namespace :database do
  desc 'Check and remove orphaned objects'
  task cleanup_orphans: :environment do
    puts 'Checking and removing orphaned objects...'

    # Tables to exclude from orphaned objects check
    excluded_tables = ['cms_templates']

    provider_account_ids = Account.where(provider: true).pluck(:id)

    ActiveRecord::Base.descendants.each do |model|
      next unless model.table_exists? && model.column_names.include?('tenant_id')
      next if excluded_tables.include?(model.table_name)

      orphaned_objects = model.where.not(tenant_id: provider_account_ids)

      if orphaned_objects.exists?
        puts "Found orphaned objects in #{model.table_name}:"
        orphaned_objects.each { |obj| puts "- ID: #{obj.id}, Tenant ID: #{obj.tenant_id}" }

        # Uncomment the line below if you want to delete orphaned objects
        # orphaned_objects.destroy_all
      else
        puts "No orphaned objects found in #{model.table_name}."
      end
    end

    puts 'Orphaned objects check completed.'
  end
end

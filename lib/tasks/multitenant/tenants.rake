# frozen_string_literal: true

namespace :multitenant do
  namespace :tenants do
    task export_org_names_to_yaml: :environment do
      File.open('tenants_organization_names.yml', 'a') do |file|
        Account.providers.select(:id, :org_name).order(:id).find_each do |account|
          file.puts("- #{account.org_name}")
        end
      end
    end

    task suspend_forbidden_plans_scheduled_for_deletion: :environment do
      puts 'Account deletion is disabled. Nothing to do.' and return unless Features::AccountDeletionConfig.enabled?
      forbidden_plans_to_be_auto_destroyed = Features::AccountDeletionConfig.config[:disabled_for_app_plans]
      query = Account.tenants.scheduled_for_deletion.where.has do
        exists Cinstance.by_account(BabySqueel[:accounts].id).by_plan_system_name(forbidden_plans_to_be_auto_destroyed).select(:id)
      end
      query.find_each(&:suspend)
      puts(query.any? ? 'Some of the tenants haven\t been suspended' : 'All the right tenants have been suspended')
    end
  end
end

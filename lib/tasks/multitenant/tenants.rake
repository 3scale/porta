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

    desc 'Fix empty or corrupted tenant_id in accounts'
    task :fix_corrupted_tenant_id_accounts, %i[batch_size sleep_time] => :environment do |_task, args|
      batch_size = (args[:batch_size] || 100).to_i
      sleep_time = (args[:sleep_time] || 1).to_i

      ids = Rails.application.simple_try_config_for(ENV['FILE']) || []

      ids.in_groups_of(batch_size).each do |group|
        puts "Executing update for a batch of size: #{group.size}"
        Account.buyers.where(id: group).update_all('tenant_id = provider_account_id') # rubocop:disable Rails/SkipsModelValidations
        Account.providers.where(id: group).update_all('tenant_id = id') # rubocop:disable Rails/SkipsModelValidations
        puts "Sleeping #{sleep_time} seconds"
        sleep(sleep_time)
      end
    end

    desc 'Fix empty or corrupted tenant_id for a table associated to account'
    task :fix_corrupted_tenant_id_for_table_associated_to_account, %i[table_name time_start time_end batch_size sleep_time] => :environment do |_task, args|
      update_tenant_ids(proc { |object| object.account.tenant_id }, proc { account }, condition_update_tenant_id(args[:time_start], args[:time_end]), args.to_hash)
    end

    desc 'Fix empty or corrupted tenant_id for a table associated to user'
    task :fix_corrupted_tenant_id_for_table_associated_to_user, %i[table_name time_start time_end batch_size sleep_time] => :environment do |_task, args|
      update_tenant_ids(proc { |object| object.user.tenant_id }, proc { user }, condition_update_tenant_id(args[:time_start], args[:time_end]), args.to_hash)
    end

    desc 'Fix empty tenant_id in access_tokens'
    task :fix_empty_tenant_id_access_tokens, %i[batch_size sleep_time] => :environment do |_task, args|
      update_tenant_ids(proc { |object| object.owner.tenant_id }, proc { owner }, proc { tenant_id == nil }, args.to_hash.merge({table_name: 'AccessToken'}))
    end

    desc 'Restore all tenant_id in alerts'
    task :restore_all_tenant_id_alerts, %i[batch_size sleep_time] => :environment do |_task, args|
      update_tenant_ids(proc { |object| object.account.tenant_id }, proc { account }, false, args.to_hash.merge({table_name: 'Alert'}))
    end

    def update_tenant_ids(tenant_id_block, association_block, condition, **args)
      query = args[:table_name].constantize.joining(&association_block)
      query = query.where.has(&condition) if condition
      puts "------ Updating #{args[:table_name]} ------"
      find_each_with_sleep(query, *args.slice(:batch_size, :sleep_time).values) do |record|
        tenant_id = tenant_id_block.call(record)
        record.update_column(:tenant_id, tenant_id) if tenant_id != Account.master.id # rubocop:disable Rails/SkipsModelValidations
      end
    end

    def find_each_with_sleep(query, batch_size, sleep_time)
      query.find_in_batches(batch_size: batch_size.to_i) do |group|
        puts "Executing update for a batch of size: #{group.size}"
        group.each { |record| yield record }
        puts "Sleeping #{sleep_time} seconds"
        sleep(sleep_time.to_i)
      end
    end

    def condition_update_tenant_id(time_start, time_end)
      proc { |object| (object.tenant_id == nil) | ((object.created_at >= Time.strptime(time_start, '%m/%d/%Y %H:%M %Z')) & (object.created_at <= Time.strptime(time_end, '%m/%d/%Y %H:%M %Z'))) }
    end
  end
end

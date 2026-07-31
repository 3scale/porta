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
      forbidden_plans_to_be_auto_destroyed = Features::AccountDeletionConfig.config.disabled_for_app_plans
      query = Account.tenants.scheduled_for_deletion.where.has do
        exists Cinstance.by_account(BabySqueel[:accounts].id).by_plan_system_name(forbidden_plans_to_be_auto_destroyed).select(:id)
      end
      query.find_each(&:suspend)
      puts(query.any? ? 'Some of the tenants haven\t been suspended' : 'All the right tenants have been suspended')
    end

    desc 'Fix in the background tenant_id missing in alerts, log entries and backend apis'
    task :fix_missing_tenant_id_async => :environment do |_task, relations|
      list = relations.to_a
      SetTenantIdWorker::BatchEnqueueWorker.validate_params(*list)
      SetTenantIdWorker::BatchEnqueueWorker.perform_later(*list)
    end

    desc 'Fix empty or corrupted tenant_id in accounts'
    task :fix_corrupted_tenant_id_accounts, %i[batch_size sleep_time] => :environment do |_task, args|
      batch_size = (args[:batch_size] || 100).to_i
      sleep_time = (args[:sleep_time] || 1).to_i

      ids = Rails.application.try_config_for(ENV['FILE']) || []

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
      update_tenant_ids(proc { |object| object.account.tenant_id }, proc { account }, condition_update_tenant_id(args[:time_start], args[:time_end]), **args.to_hash)
    end

    desc 'Fix empty or corrupted tenant_id for a table associated to user'
    task :fix_corrupted_tenant_id_for_table_associated_to_user, %i[table_name time_start time_end batch_size sleep_time] => :environment do |_task, args|
      update_tenant_ids(proc { |object| object.user.tenant_id }, proc { user }, condition_update_tenant_id(args[:time_start], args[:time_end]), **args.to_hash)
    end

    desc 'Fix empty tenant_id in access_tokens'
    task :fix_empty_tenant_id_access_tokens, %i[batch_size sleep_time] => :environment do |_task, args|
      update_tenant_ids(proc { |object| object.owner.tenant_id }, proc { owner }, proc { tenant_id == nil }, **args.to_hash.merge({ table_name: 'AccessToken' }))
    end

    desc 'Restore existing tenant_id in alerts'
    task :restore_existing_tenant_id_alerts, %i[batch_size sleep_time] => :environment do |_task, args|
      update_tenant_ids(proc { |object| object.account.tenant_id }, proc { account }, proc { tenant_id != nil }, **args.to_hash.merge({ table_name: 'Alert' }))
    end

    desc 'Restore empty tenant_id in alerts'
    task :restore_empty_tenant_id_alerts, %i[batch_size sleep_time] => :environment do |_task, args|
      update_tenant_ids(proc { |object| object.account.tenant_id }, proc { account }, proc { tenant_id == nil }, **args.to_hash.merge({ table_name: 'Alert' }))
    end

    desc 'validate tenant_id integrity'
    task :integrity => :environment do
      require "three_scale/tenant_id_integrity_checker"

      inconsistent = ThreeScale::TenantIDIntegrityChecker.new.check

      Rails.logger.error "Inconsistent tenant_ids for:\n#{inconsistent.map {_1.join(" ")}.join("\n")}"
    end

    # Schedule stale tenants for background deletion, throttled via sidekiq-throttled.
    #
    # Usage:
    #   rake multitenant:tenants:stale_throttled_delete             # default: concurrency=3, 180 days
    #   rake multitenant:tenants:stale_throttled_delete[1,365]      # concurrency=1, accounts stale for 1+ year
    #   DRY_RUN=1 rake multitenant:tenants:stale_throttled_delete   # preview without enqueuing
    #
    # Control concurrency at runtime from any Rails console (affects all pods immediately):
    #   DeleteAccountHierarchyWorker.concurrency_limit = 5   # speed up
    #   DeleteAccountHierarchyWorker.concurrency_limit = 1   # slow down
    #   DeleteAccountHierarchyWorker.concurrency_limit = 0   # pause (sidekiq-throttled cooldown kicks in)
    #   DeleteAccountHierarchyWorker.concurrency_limit        # check current value
    #
    # Stop and clear remaining queued jobs:
    #   DeleteAccountHierarchyWorker.concurrency_limit = 0
    #   Sidekiq::Queue.new("deletion").each { |job| job.delete if job["wrapped"] == "DeleteAccountHierarchyWorker" }
    #
    # Note: the concurrency limit is stored in Redis under the key "stale_deletion:concurrency_limit" and
    # persists until explicitly changed. If jobs in the deletion queue appear to not be running, check:
    #   redis-cli get stale_deletion:concurrency_limit   # 0 means paused, absent means default (3)
    desc 'Schedule stale tenants background deletion.'
    task :stale_throttled_delete, %i[concurrency days_since_disabled] => :environment do |_task, args|
      # Not using Account::States::PERIOD_BEFORE_DELETION because customers using this task
      # will probably have FindAndDeleteScheduledAccountsWorker disabled. To err on the safe side
      # we only delete ancient stuff by default.
      args.with_defaults(concurrency: 3, days_since_disabled: 30 * 6)
      target_concurrency = Integer(args.concurrency)
      since = Integer(args.days_since_disabled).days.ago
      dry_run = ENV["DRY_RUN"].present?

      scope = Account.tenants.deleted_since(since)
      total = scope.count
      Rails.logger.info "[stale_throttled_delete] #{total} accounts scheduled_for_deletion since #{since.to_date}#{' (DRY RUN)' if dry_run}"

      if dry_run
        scope.find_each do |provider|
          Rails.logger.info "[stale_throttled_delete] Would delete: id=#{provider.id} org_name=#{provider.org_name} state_changed_at=#{provider.state_changed_at&.to_date}"
        end
        next # `next` exits the task
      end

      DeleteAccountHierarchyWorker.concurrency_limit = target_concurrency
      Rails.logger.info "[stale_throttled_delete] Concurrency limit set to #{target_concurrency}"
      Rails.logger.warn "[stale_throttled_delete] Concurrency is 0 — jobs will be enqueued but NOT processed until raised" if target_concurrency.zero?

      scheduled = 0
      scope.find_each do |provider|
        DeleteAccountHierarchyWorker.delete_later(provider)
        scheduled += 1
        Rails.logger.info "[stale_throttled_delete] Scheduled #{scheduled}/#{total}: id=#{provider.id} org_name=#{provider.org_name}"
      end

      Rails.logger.info "[stale_throttled_delete] Done. Scheduled #{scheduled} accounts with concurrency #{target_concurrency}. Jobs will process in the background."
    end

    def update_tenant_ids(tenant_id_block, association_block, condition, **args)
      query = args[:table_name].constantize.joining(&association_block).where.has(&condition)
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

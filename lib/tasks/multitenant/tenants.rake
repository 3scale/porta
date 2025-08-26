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

    desc 'Schedule stale tenants background deletion.'
    task :stale_throttled_delete, %i[concurrency days_since_disabled iteration_wait] => :environment do |_task, args|
      require "progress_counter"

      # Not using Account::States::PERIOD_BEFORE_DELETION because customers using this task
      # will probably have FindAndDeleteScheduledAccountsWorker disabled. To err on the safe side
      # we only delete ancient stuff by default.
      args.with_defaults(:concurrency => 3, :days_since_disabled => 30*6, :iteration_wait => 60)
      target_concurrency = Integer(args.concurrency)
      since = Integer(args.days_since_disabled).days.ago
      iteration_wait = Integer(args.iteration_wait)

      stale_enum = Account.tenants.deleted_since(since).find_each
      progress = ProgressCounter.new(stale_enum.size)

      loop do
        current_deletion_jobs = scheduled_or_running_background_deletions
        to_schedule = target_concurrency - current_deletion_jobs.count
        already_scheduled_providers = current_deletion_jobs.filter_map { provider_being_deleted(_1) }

        to_schedule.times do
          provider = stale_enum.next # raises StopIteration which will break out of the outer loop
          redo if already_scheduled_providers.include?(provider.id)
          DeleteObjectHierarchyWorker.delete_later(provider)
          progress.call
        end

        sleep iteration_wait
      end

      Rails.logger.info "all stale tenants should be deleted or scheduled now, quitting"
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

    def scheduled_or_running_background_deletions
      [
        # I was thinking that future schedules shouldn't count towards concurrency
        # *Sidekiq::ScheduledSet.new.select { job.queue == "deletion" },
        *Sidekiq::Queue.new("deletion").to_a,
        *Sidekiq::Workers.new.filter_map { |_pid, _tid, work| work.job if work.job.queue == "deletion" },
      ]
    end

    def provider_being_deleted(job)
      if job.is_a?(Sidekiq::JobRecord) && job["wrapped"] == DeleteObjectHierarchyWorker.name
        id = job.args.first["arguments"].first.sub("Plain-Account-", "").to_i
        id unless id.zero?
      end
    end
  end
end

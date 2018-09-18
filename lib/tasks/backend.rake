namespace :backend do
  desc <<END
Generate fake usage data.

# rake backend:fake CINSTANCE_ID=290 SINCE=2011-01-02 FREQUENCY=0.00001 MAX=100 METRIC=1002509482


Parameters:
  CINSTANCE_ID    - cinstance id to generate the data for. This is required.
  PROVIDER_ID     - provider id to fetch all cinstances from. Required if no CINSTANCE_ID provided.
  SINCE           - date/time since when to generate the data. Default is when
                    the cinstance was created. (in UTC)
  UNTIL           - date/time until when to generate the data. Default is now. (in UTC)
  METRIC          - id or name of the metric to generate the data for. Default
                    is "hits".
  MIN             - minimal value of each transaction. Default is 0
  MAX             - maximal value of each transaction. Default is 1000
  FREQUENCY       - how many transactions per second on average. Default is 0.01
  HTTP            - Fake data doing http hits to backend (slow way). Default is false
END
  task :fake => :environment do
    cinstance = ENV.fetch('CINSTANCE_ID') do
      Account.find(ENV.fetch('PROVIDER_ID')).provided_cinstances.live.pluck(:id)
    end

    zone = ActiveSupport::TimeZone.new('UTC')
    time_since = ENV['SINCE'].present? ? zone.parse(ENV['SINCE']) : nil
    time_until = ENV['UNTIL'].present? ? zone.parse(ENV['UNTIL']) : nil

    generator = ENV['WORKER'] ? BackendRandomDataGeneratorWorker : Backend::RandomDataGenerator

    Array(cinstance).map do |id|
      puts "generating fake traffic for application #{id}"

      metric = ENV.fetch('METRIC') do
        Cinstance.find(id).provider_account.metrics.reorder(:id).pluck(:system_name)
      end

      cinstance = Cinstance.find(id)

      Array(metric).each do |metric_name|
        begin
          metric = Backend::RandomDataGenerator.find_metric(cinstance, metric_name).id
        rescue ActiveRecord::RecordNotFound
          warn "no metric #{metric_name} for service #{cinstance.service_id}"
          next
        end

        begin
          generator.generate(
            cinstance_id: id,
            since: time_since,
            until: time_until,
            metric: metric,
            min: ENV['MIN'],
            max: ENV['MAX'],
            frequency: ENV['FREQUENCY'],
            http: ENV['HTTP'],
          )
        rescue Backend::LimitsExceeded
          puts "limits exceeded for cinstance #{id}"
        end
      end
    end
  end

  namespace :storage do
    desc "Seed the storage with data needed by the backend."
    task :seed => [:environment, :rewrite] do
      # Create new master account metrics
      master_metrics = Account.master.first_service!.metrics

      unless master_metrics.find_by_name('transactions')
        master_metrics.create!(:name => 'transactions',
                               :friendly_name => 'Number of transactions',
                               :unit => 'transaction')
      end
    end

    desc "Import application keys and referrer filters to MySQL"
    task :import_app_keys_and_filters => :environment do
      Cinstance.find_each do |cinstance|

        next if cinstance.provider_account.nil? # weirdness, possibly issue with master itself

        cinstance.keys.each do |key|
          cinstance.application_keys.create! :value => key unless cinstance.application_keys.map{|k| k.value}.include?(key)
        end
        cinstance.referrers.each do |ref|
          cinstance.referrer_filters.create! :value => ref unless cinstance.referrer_filters.map{|k| k.value}.include?(ref)
        end
      end
    end

    # FIXME: delete non-existing keys too
    #

    rewrite_progress = lambda do |percent|
      puts "#{percent.round(2)}% completed"
    end

    desc "Rewrite the data needed by the backend."
    task :rewrite => :environment do
      next if Rails.env.test? || System::Application.config.three_scale.core.fake_server

      if ENV['PROVIDER_ID']
         break Rake::Task['backend:storage:rewrite_provider'].invoke
      end

      Backend::StorageRewrite.rewrite_all(&rewrite_progress)
    end

    desc "Rewrites all the content of a single provider"
    task :rewrite_provider => :environment do
      Backend::StorageRewrite.rewrite_provider(ENV['PROVIDER_ID'], &rewrite_progress)
    end

    desc 'Enqueue job for every provider to do backend storage rewrite.'
    task :enqueue_rewrite => :environment do
      accounts = Account.providers_with_master
      BackendStorageRewriteWorker.enqueue_all(accounts)
      puts "Enqueued #{accounts.count} accounts for rewrite"
    end

    desc "Regenerate provider keys."
    task :regenerate_provider_keys => :environment do
      accounts = Account.providers_with_master
      if (provider_id = ENV["PROVIDER_ID"])
        accounts = accounts.where(id: provider_id)
      end
      cinstances = accounts.flat_map{|p| p.bought_cinstances }
      total_count = cinstances.size
      index = 0
      progress = lambda do
        percent = ((index + 1) / total_count.to_f) * 100.0
        puts "#{percent.round(2)}% completed"
        index += 1
      end

      cinstances.each do |cinstance|
        cinstance.change_user_key!
        progress.call
      end
    end

    desc "Regenerate 'clean-*' user keys"
    task :regenerate_clean_keys => :environment do
      cinstances = Cinstance.find(:all, :conditions => "user_key like 'clean-%'")
      total_count = cinstances.size
      index = 0
      progress = lambda do
        percent = ((index + 1) / total_count.to_f) * 100.0
        puts "#{percent.round(2)}% completed"
        index += 1
      end

      cinstances.each do |cinstance|
        cinstance.change_user_key!
        progress.call
      end
    end
  end
end

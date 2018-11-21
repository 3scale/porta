namespace :ci do

  namespace :db do

    desc 'Wait for database to boot, with `DB_BOOT_TIMEOUT` and `DB_BOOT_SLEEP_SECONDS` interval'
    task :ready do
      timeout = ENV.fetch('DB_BOOT_TIMEOUT', 300).to_i
      interval = ENV.fetch('DB_BOOT_SLEEP_SECONDS', 1).to_i

      if ENV['DB'] == 'oracle'
        # allow some startup time for oracle to boot...  ¯\_(ツ)_/¯
        sleep 300
      end

      require 'system/database'
      until System::Database.ready? || timeout.negative?
        print '.'
        sleep interval
        timeout = timeout - interval
      end

      if ENV['DB'] == 'oracle'
        # allow some MORE time for setup to complete in oracle...  ¯\_(ツ)_/¯
        sleep 300
      end

    end

  end
end
namespace :ci do

  namespace :db do

    desc 'Wait for database to boot, with `DB_BOOT_TIMEOUT` and `DB_BOOT_SLEEP_SECONDS` interval'
    task :ready do
      timeout = ENV.fetch('DB_BOOT_TIMEOUT', 300).to_i
      interval = ENV.fetch('DB_BOOT_SLEEP_SECONDS', 1).to_i

      require 'system/database'
      until System::Database.ready? || timeout.negative?
        print '.'
        sleep interval
        timeout = timeout - interval
      end
    end

  end
end
namespace :db do
  namespace :data do
    desc "Dump the current database to a MySQL file. Use EXCLUDE_USAGE=true to exclude the huge usage tables."
    task :dump => :environment do
      config = ActiveRecord::Base.configurations[Rails.env].dup

      options = ' --add-drop-table --single-transaction'

      if tenant_id = ENV['TENANT_ID']
        options << %{ --where="tenant_id = #{tenant_id} OR tenant_id IS NULL"}
      end

      if ENV['EXCLUDE_USAGE']
        usage_tables = %w[service_transactions reports]
        usage_tables.each do |table|
          options << " --ignore-table=#{config['database']}.#{table}"
        end
      end

      system "mysqldump #{mysql_params(config)}#{options} #{config['database']} > #{Rails.root}/db/data.sql"
    end

    desc "Load data from db/data.sql into current database, erasing any previous content"
    task :load => :environment do
      confirm_production_kill

      dump = ENV['SOURCE'] || "#{Rails.root}/db/data.sql"

      unless File.exist?(dump)
        abort %{No database dump found (#{dump}). Run \"cap db:dump\" first.}
      end

      config = ActiveRecord::Base.configurations[Rails.env]

      puts "Loading data from #{dump} into #{config['database']} database..."
      system "mysql #{mysql_params(config)} -D #{config['database']} < #{dump}"

      puts "Running migrations (if any)..."
      Rake::Task['db:migrate'].execute({})

      puts "Done."
    end

    desc "Clear all data from database, keeping the structure"
    task :clear => :environment do
      confirm_production_kill

      ActiveRecord::Base.establish_connection
      connection = ActiveRecord::Base.connection

      tables = connection.select_values('SHOW TABLES')

      connection.disable_referential_integrity do
        tables.each do |table|
          puts "Clearing table #{table}..."
          connection.execute("TRUNCATE #{table}")
        end
      end
    end

    def mysql_params(config)
      params = ""
      params << " --host=#{config["host"]}" if config["host"]
      params << " --socket=#{config["socket"]}" if config["socket"]
      params << " --user=#{config["username"]}" if config["username"]
      params << " --password=#{config["password"]}" if config["password"]
      params
    end

    def confirm_production_kill
      if Rails.env.production? && ENV['FORCE'].blank?
        abort "Are you sure you want to kill your PRODUCTION DATABASE? " +
              "If yes, run this task with parameter FORCE=true."
      end
    end
  end
end

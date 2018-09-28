# frozen_string_literal: true

require 'system/database'

namespace :db do
  task :test => :environment do
    ActiveRecord::Base.establish_connection(:test)
  end

  desc "Loads functions and stored procedures to test database"
  task 'test:procedures' => ['db:test', 'db:procedures']

  procedures = []

  namespace :procedures do
    task :oracle => :environment do
      procedure_body = <<~SQL
        DECLARE
          _provider_account_id int;
          _period: date;
          _friendly_id: varchar(255);
          _numbering_period: varchar(255);
          _invoice_prefix_format: varchar(255);
          _invoice_prefix: varchar(255);
          _invoice_counter_id: int;
          _invoice_count: int;
        BEGIN
          SELECT provider_account_id, period, friendly_id
          INTO _provider_account_id, _period, _friendly_id
          FROM invoices
          WHERE invoices.id = invoice_id;

          IF _friendly_id IS NULL OR _friendly_id = 'fix' THEN
            SELECT numbering_period
            INTO _numbering_period
            FROM billing_strategies
            WHERE account_id = _provider_account_id
            AND ROWNUM = 1;

            IF _numbering_period = 'monthly' THEN
              _invoice_prefix_format := 'YYYY-MM';
            ELSE
              _invoice_prefix_format := 'YYYY';
            END IF;

            _invoice_prefix := TO_CHAR(_period, _invoice_prefix_format);

            SELECT id, invoice_count
            INTO _invoice_counter_id, _invoice_count
            FROM invoice_counters
            WHERE provider_account_id = _provider_account_id AND invoice_prefix = _invoice_prefix
            AND ROWNUM = 1
            FOR UPDATE;

            UPDATE invoices
            SET friendly_id = CONCAT(_invoice_prefix, '-', LPAD(COALESCE(_invoice_count, 0) + 1, 8, '0'))
            WHERE id = invoice_id;

            UPDATE invoice_counters
            SET invoice_count = invoice_count + 1, updated_at = CURRENT_TIMESTAMP
            WHERE id = _invoice_counter_id;
          END IF;
        END;
      SQL

      procedures << System::Database::OracleStoredProcedure.new('sp_invoices_friendly_id', procedure_body, invoice_id: 'bigint(20)')
    end

    task :mysql => :environment do
      procedure_body = <<~SQL
        BEGIN
          DECLARE _provider_account_id bigint(20);
          DECLARE _period date;
          DECLARE _friendly_id varchar(255);

          SELECT provider_account_id, period, friendly_id
          INTO _provider_account_id, _period, _friendly_id
          FROM invoices
          WHERE invoices.id = invoice_id;

          IF _friendly_id IS NULL OR _friendly_id = 'fix' THEN
            SET @numbering_period = (SELECT numbering_period
                                     FROM billing_strategies
                                     WHERE account_id = _provider_account_id
                                     LIMIT 1);

            IF @numbering_period = 'monthly' THEN
              SET @invoice_prefix_format = "%Y-%m";
            ELSE
              SET @invoice_prefix_format = "%Y";
            END IF;

            SET @invoice_prefix = DATE_FORMAT(_period, @invoice_prefix_format);

            UPDATE invoices i INNER JOIN invoice_counters c
            ON i.provider_account_id = c.provider_account_id AND c.invoice_prefix = @invoice_prefix
            SET
              i.friendly_id = CONCAT(@invoice_prefix, '-', LPAD(COALESCE(c.invoice_count, 0) + 1, 8, '0')),
              c.invoice_count = c.invoice_count + 1,
              c.updated_at = CURRENT_TIMESTAMP()
            WHERE i.id = invoice_id;
          END IF;
        END;
      SQL

      procedures << System::Database::MySQLStoredProcedure.new('sp_invoices_friendly_id', procedure_body, invoice_id: 'bigint')
    end

    task :load_procedures do
      if System::Database.oracle?
        Rake::Task['db:procedures:oracle'].invoke
      elsif System::Database.mysql?
        Rake::Task['db:procedures:mysql'].invoke
      else
        raise 'unsupported database procedures'
      end
    end

    task :create => %I[environment load_procedures] do
      procedures.each do |t|
        ActiveRecord::Base.connection.execute(t.create)
      end
    end

    task :drop => %I[environment load_procedures] do
      procedures.each do |t|
        ActiveRecord::Base.connection.execute(t.drop)
      end
    end
  end

  desc 'Recreates the DB triggers (delete+create)'
  task :procedures => %I[environment procedures:load_procedures] do
    puts "Recreating procedures, see log/#{Rails.env}.log"
    procedures.each do |procedure|
      procedure.recreate.each do |command|
        ActiveRecord::Base.connection.execute(command)
      end
    end
    puts "Recreated #{procedures.size} procedures"
  end
end

Rake::Task['db:seed'].enhance(['db:procedures'])

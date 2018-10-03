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
          v_provider_account_id NUMBER;
          v_period date;
          v_friendly_id varchar(255);
          v_numbering_period varchar(255);
          v_invoice_prefix_format varchar(255);
          v_invoice_prefix varchar(255);
          v_invoice_counter_id NUMBER;
          v_invoice_count NUMBER;
        BEGIN
          SELECT provider_account_id, period, friendly_id
          INTO v_provider_account_id, v_period, v_friendly_id
          FROM invoices
          WHERE invoices.id = invoice_id
          AND ROWNUM = 1;

          IF v_friendly_id IS NULL OR v_friendly_id = 'fix' THEN
            SELECT numbering_period
            INTO v_numbering_period
            FROM billing_strategies
            WHERE account_id = v_provider_account_id
            AND ROWNUM = 1;

            IF v_numbering_period = 'monthly' THEN
              v_invoice_prefix_format := 'YYYY-MM';
            ELSE
              v_invoice_prefix_format := 'YYYY';
            END IF;

            v_invoice_prefix := TO_CHAR(v_period, v_invoice_prefix_format);

            SELECT id, invoice_count
            INTO v_invoice_counter_id, v_invoice_count
            FROM invoice_counters
            WHERE provider_account_id = v_provider_account_id AND invoice_prefix = v_invoice_prefix
            AND ROWNUM = 1
            FOR UPDATE;

            UPDATE invoices
            SET friendly_id = v_invoice_prefix || '-' || LPAD(COALESCE(v_invoice_count, 0) + 1, 8, '0')
            WHERE id = invoice_id;

            UPDATE invoice_counters
            SET invoice_count = invoice_count + 1, updated_at = CURRENT_TIMESTAMP
            WHERE id = v_invoice_counter_id;
          END IF;
        END;
      SQL

      procedures << System::Database::OracleStoredProcedure.new('sp_invoices_friendly_id', procedure_body, invoice_id: 'NUMBER')
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

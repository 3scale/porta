# frozen_string_literal: true

module System
  module Database
    module Postgres
      class Procedure < ::System::Database::Procedure
        def drop
          <<~SQL
            DROP FUNCTION IF EXISTS #{name}
          SQL
        end

        def create
          <<~SQL
            CREATE OR REPLACE FUNCTION #{signature} RETURNS void AS $$
            #{body}
            $$ LANGUAGE plpgsql;
          SQL
        end
      end
    end
  end
end

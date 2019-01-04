# frozen_string_literal: true

module System
  module Database
    module Postgres
      class TriggerProcedure < Procedure
        def create
          <<~SQL
            CREATE OR REPLACE FUNCTION #{name}() RETURNS trigger AS $$
            #{body}
            $$ LANGUAGE plpgsql;
          SQL
        end
      end
    end
  end
end

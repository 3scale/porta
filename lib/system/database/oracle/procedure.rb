# frozen_string_literal: true

module System
  module Database
    module Oracle
      class Procedure < ::System::Database::Procedure
        def params_declaration
          pairs = params.map { |name, type| "#{name} #{type}" }
          "(#{pairs.join(', ')})"
        end

        def drop
          <<~SQL
            BEGIN
               EXECUTE IMMEDIATE 'DROP PROCEDURE #{name}';
            EXCEPTION
              WHEN OTHERS THEN
                IF SQLCODE != -4043 THEN
                  RAISE;
                END IF;
            END;
          SQL
        end

        def create
          <<~SQL
            CREATE OR REPLACE PROCEDURE #{signature} AS
            #{body}
          SQL
        end
      end
    end
  end
end

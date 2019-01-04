# frozen_string_literal: true

module System
  module Database
    module MySQL
      class Procedure < ::System::Database::Procedure
        def drop
          <<~SQL
            DROP PROCEDURE IF EXISTS #{name}
          SQL
        end

        def create
          <<~SQL
            CREATE PROCEDURE #{signature} #{body}
          SQL
        end
      end
    end
  end
end

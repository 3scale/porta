# frozen_string_literal: true

module System
  module Database
    class StoredProcedure
      def initialize(name, body, params = {})
        @name = name
        @body = body
        @params = params
      end

      def drop
        raise NotImplementedError
      end

      def create
        raise NotImplementedError
      end

      def recreate
        [drop, create]
      end

      protected

      attr_reader :name, :body, :params

      def params_declaration
        pairs = params.map { |name, type| "#{name} #{type}" }
        "(#{pairs.join(', ')})"
      end

      def signature
        [name, params_declaration].join
      end
    end
    private_constant :StoredProcedure

    class OracleStoredProcedure < StoredProcedure
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

    class MySQLStoredProcedure < StoredProcedure
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

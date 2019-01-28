# frozen_string_literal: true

module System
  module Database
    module MySQL
      class Trigger < ::System::Database::Trigger
        def drop
          <<~SQL
            DROP TRIGGER IF EXISTS #{name}
          SQL
        end

        def body
          <<~SQL
            BEGIN
              DECLARE master_id numeric;
              IF @disable_triggers IS NULL THEN
                IF NEW.tenant_id IS NULL THEN
                  #{set_master_id};
                  #{trigger}
                END IF;
              END IF;
            END;
          SQL
        end

        def set_master_id
          select = begin
                     master_id
                   rescue ActiveRecord::RecordNotFound
                     <<~SQL
                       (SELECT id FROM accounts WHERE master)
                     SQL
                   end
          "SET master_id = #{select}"
        end
      end
    end
  end
end

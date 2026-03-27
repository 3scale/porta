class HashAccessTokenValues < ActiveRecord::Migration[7.1]
  disable_ddl_transaction! if System::Database.postgres?

  BATCH_SIZE = 1000
  DIGEST_PREFIX = 'SHA384$'.freeze

  def up
    say "Hashing legacy access token values..."

    loop do
      rows_updated = exec_update(batch_update_sql)
      break if rows_updated == 0

      sleep(0.1)
    end

    say "Done."
  end

  private

  def batch_update_sql
    if System::Database.mysql?
      "UPDATE access_tokens SET value = CONCAT('#{DIGEST_PREFIX}', SHA2(value, 384)) " \
        "WHERE value NOT LIKE '#{DIGEST_PREFIX}%' LIMIT #{BATCH_SIZE}"
    elsif System::Database.postgres?
      "UPDATE access_tokens SET value = '#{DIGEST_PREFIX}' || encode(sha384(value::bytea), 'hex') " \
        "WHERE id IN (SELECT id FROM access_tokens WHERE value NOT LIKE '#{DIGEST_PREFIX}%' LIMIT #{BATCH_SIZE})"
    elsif System::Database.oracle?
      "UPDATE access_tokens SET value = '#{DIGEST_PREFIX}' || LOWER(STANDARD_HASH(value, 'SHA384')) " \
        "WHERE ROWID IN (SELECT ROWID FROM access_tokens WHERE value NOT LIKE '#{DIGEST_PREFIX}%' AND ROWNUM <= #{BATCH_SIZE})"
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end

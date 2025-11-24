# frozen_string_literal: true

# Export/Import all data from/to database via stdin/stdout
# Usage:
#   RAILS_LOG_TO_STDOUT=false bundle exec rails runner dump_data.rb export > data.jsonl
#   bundle exec rails runner dump_data.rb import < data.jsonl
#
# Make Porta Operational:
#   If importing from a different base domain, setup config/domain_substitution.yml
#   Make sure apicast uses:
#    * correct master account url (Account.master #domain and #self_domain)
#    * correct token, see master -> account settings -> personal -> tokens
#   Resync backend: bundle exec rake backend:storage:enqueue_rewrite
#   If apicast domains are changing: Proxy.find_each { _1.update_domains; _1.save! }

require 'json'

# Eager load all Rails models so find_model_for_table can find them
Rails.application.eager_load!

# Redirect all Rails logging to STDERR to avoid polluting STDOUT
# This catches any logs that happen after Rails initialization
if Rails.logger
  Rails.logger = Logger.new(STDERR)
  Rails.logger.level = Logger::WARN
end

if defined?(ActiveRecord::Base)
  ActiveRecord::Base.logger = Logger.new(STDERR)
  ActiveRecord::Base.logger.level = Logger::WARN
end

BATCH_SIZE = 1000

# Skip these internal tables
SKIP_TABLES = [
  'schema_migrations',
  'ar_internal_metadata'
].freeze

# Find ActiveRecord model for a given table name
# Searches through all ActiveRecord descendants to handle namespaced models
# Filters out STI subclasses to avoid duplicate processing
def find_model_for_table(table_name)
  ActiveRecord::Base.descendants.find do |model|
    begin
      # Skip if this is an STI subclass (has a different base_class)
      next if model.base_class != model

      # Check if table name matches
      model.table_name == table_name
    rescue => e
      # Some models might not have a table_name (abstract classes, etc.)
      false
    end
  end
end

# Get list of tables to process, excluding internal tables
# Returns tables in sorted order
def get_tables_to_process
  tables = ActiveRecord::Base.connection.tables.sort

  # Filter out internal tables
  tables.reject! do |table|
    SKIP_TABLES.include?(table) || table =~ /^(MLOG\$|RUPD\$|BIN\$)/
  end

  tables
end

def export_data
  tables = get_tables_to_process

  # Tables with foreign key constraints that should be imported last
  # Based on foreign keys defined in db/oracle_schema.rb
  tables_with_fk_dependencies = [
    'api_docs_services',      # FK to services
    'payment_details',        # FK to accounts
    'policies',               # FK to accounts
    'provided_access_tokens', # FK to users
    'proxy_configs',          # FK to proxies, users
    'sso_authorizations'      # FK to authentication_providers, users
  ]

  # Move tables with foreign keys to the end in dependency order
  tables_with_fk_dependencies.each do |table|
    tables << table if tables.delete(table)
  end

  STDERR.puts "Exporting data from #{tables.size} tables..."
  STDERR.puts "=" * 80

  exported_count = 0
  total_records = 0

  tables.each do |table|
    begin
      # Try to find model for this table
      model = find_model_for_table(table)

      # Get total count first
      record_count = if model
        model.count
      else
        count_sql = "SELECT COUNT(*) FROM #{ActiveRecord::Base.connection.quote_table_name(table)}"
        count_result = ActiveRecord::Base.connection.exec_query(count_sql)
        count_result.rows.first.first
      end

      if record_count == 0
        STDERR.puts "#{table}: 0 records (empty)"
        # Output empty batch to ensure table gets truncated on import
        puts JSON.generate({ table: table, data: [] })
        exported_count += 1
        next
      end

      STDERR.print "#{table}: exporting #{record_count} records..."

      batch_count = 0

      if model
        # Check if table has composite primary key
        has_composite_key = model.primary_key.nil? || model.primary_key.is_a?(Array)

        # Get valid column names to filter out virtual attributes (like tag_list)
        valid_columns = model.column_names

        if has_composite_key
          # For composite primary keys, fetch all at once using the model
          # find_each requires ORDER BY which doesn't work with composite keys
          # Use model.all to get proper type serialization
          # Filter to only include actual database columns (exclude virtual attributes)
          all_records = model.all.map { |r| r.attributes.slice(*valid_columns) }

          all_records.each_slice(BATCH_SIZE) do |batch|
            puts JSON.generate({ table: table, data: batch })
            batch_count += 1
            total_records += batch.size
          end
        else
          # Identify serialized columns
          serialized_columns = []
          if model.respond_to?(:serialized_attributes)
            # Rails < 7.1
            serialized_columns = model.serialized_attributes.keys
          else
            # Rails >= 7.1 - check attribute types
            serialized_columns = model.attribute_types.select { |_, type|
              type.is_a?(ActiveRecord::Type::Serialized)
            }.keys
          end

          # Single primary key - use model's find_each for proper type serialization
          model.find_each(batch_size: BATCH_SIZE).each_slice(BATCH_SIZE) do |batch|
            # Convert to hash format matching the import expectations
            # Filter to only include actual database columns (exclude virtual attributes)
            batch_data = batch.map do |record|
              attrs = record.attributes.slice(*valid_columns)

              # For serialized columns, get the raw database value (YAML string)
              # instead of the deserialized Ruby object
              serialized_columns.each do |col|
                if attrs.key?(col)
                  # Read the raw value from the database using read_attribute_before_type_cast
                  attrs[col] = record.read_attribute_before_type_cast(col)
                end
              end

              attrs
            end

            puts JSON.generate({ table: table, data: batch_data })
            batch_count += 1
            total_records += batch_data.size
          end
        end
      else
        # No model found, use raw SQL
        # Export using select_all which streams results
        # This avoids ORDER BY issues with composite primary keys
        sql = "SELECT * FROM #{ActiveRecord::Base.connection.quote_table_name(table)}"

        ActiveRecord::Base.connection.select_all(sql).each_slice(BATCH_SIZE) do |batch|
          puts JSON.generate({ table: table, data: batch })
          batch_count += 1
          total_records += batch.size
        end
      end

      STDERR.puts " ✓ (#{batch_count} batches)"
      exported_count += 1

    rescue => e
      STDERR.puts "ERROR: #{e.class}: #{e.message}"
    end
  end

  STDERR.puts "=" * 80
  STDERR.puts "Export complete!"
  STDERR.puts "Exported: #{exported_count} tables"
  STDERR.puts "Total records: #{total_records}"
end

# Insert a record using ActiveRecord model to handle LOBs properly
# This approach avoids Oracle empty_clob()/empty_blob() issues
def insert_record_with_model(model, record)
  # Identify serialized columns
  serialized_columns = []
  if model.respond_to?(:serialized_attributes)
    # Rails < 7.1
    serialized_columns = model.serialized_attributes.keys
  else
    # Rails >= 7.1 - check attribute types
    serialized_columns = model.attribute_types.select { |_, type|
      type.is_a?(ActiveRecord::Type::Serialized)
    }.keys
  end

  # Prepare attributes - deserialize serialized columns first
  attrs = {}
  record.each do |key, value|
    if serialized_columns.include?(key) && value.is_a?(String)
      # Deserialize YAML string to Ruby object
      type = model.attribute_types[key]
      attrs[key] = type.deserialize(value)
    else
      attrs[key] = value
    end
  end

  # Use model.save with ALL callbacks disabled
  # This allows proper Oracle LOB handling while bypassing all callbacks

  # For STI models, use the correct subclass from the 'type' column if present
  actual_model = model
  if attrs['type'].present?
    begin
      actual_model = attrs['type'].constantize
    rescue NameError
    end
  end

  # Use allocate to create instance without calling initialize (which filters attributes)
  instance = actual_model.new

  # Set each attribute directly, bypassing mass assignment protection and custom setters
  attrs.each do |key, value|
    instance.send(:write_attribute, key, value)
  end

  # disable running any callbacks
  instance.instance_variable_set(:@_create_callbacks_ran, true)
  instance.instance_variable_set(:@_update_callbacks_ran, true)

  # Override the run_callbacks method to do nothing
  def instance.run_callbacks(_kind, &block)
    # Just run the block (the actual save operation) without any callbacks
    block.call if block
  end

  # Save without validations
  res = instance.save(validate: false)

  unless res
    STDERR.puts "DEBUG: Save failed!"
    STDERR.puts "  Errors: #{instance.errors.full_messages.inspect}"
    STDERR.puts "  New record?: #{instance.new_record?}"
    STDERR.puts "  Persisted?: #{instance.persisted?}"
    raise ActiveRecord::RecordNotSaved, "Failed to save: #{instance.errors.full_messages.join(', ')}"
  end
end

# Iterate over each line from stdin (JSONL format)
# Yields table name and data array to the block
# Handles JSON parsing errors gracefully
def each_dump_line
  line_number = 0

  STDIN.each_line do |line|
    line_number += 1
    begin
      line_data = JSON.parse(line)
      table = line_data['table']
      data = line_data['data']

      yield(table, data, line_number)
    rescue JSON::ParserError => e
      STDERR.puts "Warning: JSON parse error on line #{line_number}: #{e.message}"
    rescue => e
      STDERR.puts "Warning: Error on line #{line_number}: #{e.message}"
    end
  end
end

# Truncate or delete a single table
# Tries TRUNCATE first, falls back to DELETE if that fails
# Returns true if successful, false otherwise
def truncate_or_delete_table(table)
  begin
    ActiveRecord::Base.connection.execute(
      "TRUNCATE TABLE #{ActiveRecord::Base.connection.quote_table_name(table)}"
    )
    true
  rescue => truncate_error
    # If truncate fails, try DELETE
    begin
      ActiveRecord::Base.connection.execute(
        "DELETE FROM #{ActiveRecord::Base.connection.quote_table_name(table)}"
      )
      true
    rescue => delete_error
      raise delete_error
    end
  end
end

# Fix auto-increment sequences for a table after importing data
# Supports Oracle, PostgreSQL, and MySQL
def fix_sequences(table)
  adapter = ActiveRecord::Base.connection.adapter_name.downcase

  case adapter
  when /oracle/
    fix_oracle_sequence(table)
  when /postgres/
    fix_postgres_sequence(table)
  when /mysql/
    fix_mysql_sequence(table)
  else
    # Unknown adapter, skip
    STDERR.puts "  -> Sequence fix not supported for adapter: #{adapter}"
  end
rescue => e
  STDERR.puts "  -> Warning: Failed to fix sequence for #{table}: #{e.message}"
end

# Fix Oracle sequence by dropping and recreating with correct START WITH
def fix_oracle_sequence(table)
  # Oracle naming convention: table_name + '_seq'
  # For long table names, Oracle Enhanced Adapter truncates the table name before adding '_seq'
  # The limit depends on the IDENTIFIER_MAX_LENGTH setting (30 or 128)

  # Get the identifier max length from the Oracle Enhanced Adapter constant
  identifier_max_length = ActiveRecord::ConnectionAdapters::OracleEnhanced::DatabaseLimits::IDENTIFIER_MAX_LENGTH

  # Try full sequence name first
  full_sequence_name = "#{table}_seq".upcase

  # Also try shortened version: table name truncated to (identifier_max_length - 4) chars + '_seq'
  # This matches the logic in activerecord-oracle_enhanced-adapter's default_sequence_name method:
  # table_name.gsub(/(^|\.)([\w$-]{1,#{sequence_name_length - 4}})([\w$-]*)$/, '\1\2_seq')
  max_table_name_prefix = identifier_max_length - 4
  shortened_sequence_name = "#{table[0, max_table_name_prefix]}_seq".upcase

  # Check which sequence exists
  sequence_name = nil
  [full_sequence_name, shortened_sequence_name].uniq.each do |seq_name|
    seq_exists_sql = "SELECT COUNT(*) FROM user_sequences WHERE sequence_name = '#{seq_name}'"
    seq_result = ActiveRecord::Base.connection.exec_query(seq_exists_sql)

    if seq_result.rows.first.first.to_i > 0
      sequence_name = seq_name
      break
    end
  end

  if sequence_name.nil?
    raise "sequence not found (tried: #{full_sequence_name}, #{shortened_sequence_name}). " \
          "Table may be using a different auto-increment mechanism. " \
          "Oracle Enhanced Adapter supports: :sequence (default), :trigger, :identity, or :autogenerated."
  end

  # Get max ID from table
  max_id_sql = "SELECT NVL(MAX(id), 0) FROM #{ActiveRecord::Base.connection.quote_table_name(table)}"
  result = ActiveRecord::Base.connection.exec_query(max_id_sql)
  max_id = result.rows.first.first.to_i

  # Get current sequence properties
  seq_props_sql = "SELECT increment_by, min_value, max_value, cache_size, cycle_flag, order_flag FROM user_sequences WHERE sequence_name = '#{sequence_name}'"
  props = ActiveRecord::Base.connection.exec_query(seq_props_sql).rows.first

  increment_by, min_value, max_value, cache_size, cycle_flag, order_flag = props

  # Drop and recreate sequence
  ActiveRecord::Base.connection.execute("DROP SEQUENCE #{sequence_name}")

  new_value = max_id + 1
  create_sql = "CREATE SEQUENCE #{sequence_name} START WITH #{new_value} INCREMENT BY #{increment_by} MINVALUE #{min_value} MAXVALUE #{max_value} CACHE #{cache_size}"
  create_sql += cycle_flag == 'Y' ? ' CYCLE' : ' NOCYCLE'
  create_sql += order_flag == 'Y' ? ' ORDER' : ' NOORDER'

  ActiveRecord::Base.connection.execute(create_sql)

  STDERR.puts "  -> Reset sequence #{sequence_name} to #{new_value}"
rescue => e
  # Silently ignore if table has no id column or other issues
end

# Fix PostgreSQL sequence using setval
def fix_postgres_sequence(table)
  sequence_name = "#{table}_id_seq"

  # Get max ID from table
  max_id_sql = "SELECT COALESCE(MAX(id), 0) FROM #{ActiveRecord::Base.connection.quote_table_name(table)}"
  result = ActiveRecord::Base.connection.exec_query(max_id_sql)
  max_id = result.rows.first.first.to_i

  # Set sequence to max_id + 1
  new_value = max_id + 1
  ActiveRecord::Base.connection.execute("SELECT setval('#{sequence_name}', #{new_value}, false)")

  STDERR.puts "  -> Reset sequence #{sequence_name} to #{new_value}"
rescue => e
  # Silently ignore if sequence doesn't exist or table has no id column
end

# Fix MySQL auto_increment
def fix_mysql_sequence(table)
  # Get max ID from table
  max_id_sql = "SELECT IFNULL(MAX(id), 0) FROM #{ActiveRecord::Base.connection.quote_table_name(table)}"
  result = ActiveRecord::Base.connection.exec_query(max_id_sql)
  max_id = result.rows.first.first.to_i

  # Set auto_increment to max_id + 1
  new_value = max_id + 1
  ActiveRecord::Base.connection.execute("ALTER TABLE #{ActiveRecord::Base.connection.quote_table_name(table)} AUTO_INCREMENT = #{new_value}")

  STDERR.puts "  -> Reset auto_increment for #{table} to #{new_value}"
rescue => e
  # Silently ignore if table has no id column or auto_increment
end

def import_data(truncate: true)
  STDERR.puts "Reading data from stdin (line-by-line JSONL format)..."
  STDERR.puts "Truncate mode: #{truncate ? 'ENABLED' : 'DISABLED'}"
  STDERR.puts "=" * 80

  imported_tables = {}
  total_records = 0

  # Read line by line from stdin using shared iterator
  each_dump_line do |table, data, line_number|
    # Track which tables we're importing
    imported_tables[table] ||= 0

    # Truncate table if requested and not already truncated
    if truncate && imported_tables[table]
        truncate_or_delete_table(table)
    end

    next if data.nil? || data.empty?

    # Use individual insert statements for each record
    # Exit immediately on first failure
    # Find model to get attribute types
    model = find_model_for_table(table)

    data.each do |record|
      begin
        if model
          # Filter out virtual attributes (like tag_list from acts-as-taggable-on)
          # Only keep attributes that correspond to actual database columns
          valid_columns = model.column_names
          filtered_record = record.select { |k, _| valid_columns.include?(k) }

          # Use helper method to handle text/CLOB attributes separately
          insert_record_with_model(model, filtered_record)
        else
          # No model found, use raw SQL
          columns = record.keys
          quoted_columns = columns.map { |k| ActiveRecord::Base.connection.quote_column_name(k) }

          # Detect and format datetime strings for Oracle
          quoted_values = record.values.map do |v|
            if v.nil?
              'NULL'
            elsif v.is_a?(String) && v =~ /^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}( UTC)?$/
              # Datetime string detected, use TO_TIMESTAMP for Oracle
              datetime_str = v.sub(/ UTC$/, '') # Remove UTC suffix if present
              "TO_TIMESTAMP(#{ActiveRecord::Base.connection.quote(datetime_str)}, 'YYYY-MM-DD HH24:MI:SS')"
            else
              ActiveRecord::Base.connection.quote(v)
            end
          end

          sql = "INSERT INTO #{ActiveRecord::Base.connection.quote_table_name(table)} "
          sql += "(#{quoted_columns.join(', ')}) VALUES (#{quoted_values.join(', ')})"

          ActiveRecord::Base.connection.execute(sql)
        end

        imported_tables[table] += 1
        total_records += 1

        # Show progress every 10 batches per table
        if imported_tables[table] % (BATCH_SIZE * 10) == 0
          STDERR.puts "."
        end

      rescue => error
        STDERR.puts "\n  -> ERROR importing #{table} on line #{line_number}: #{error.class}: #{error.message}"
        STDERR.puts "  -> Failed record: #{record.inspect}"
        STDERR.puts "\n  -> Backtrace:"
        STDERR.puts error.backtrace.first(3).join("\n")
        STDERR.puts "  -> Exiting due to error"
        exit 1
      end
    end

    # Fix sequences after processing each batch line
    fix_sequences(table)
  end

  STDERR.puts ""
  STDERR.puts "=" * 80
  STDERR.puts "Import complete!"

  imported_tables.each do |table, count|
    STDERR.puts "  #{table}: #{count} records"
  end

  STDERR.puts "Total tables: #{imported_tables.keys.size}"
  STDERR.puts "Total records: #{total_records}"
end

def truncate_all_tables
  STDERR.puts "Reading table list from stdin (line-by-line JSONL format)..."
  STDERR.puts "Will truncate all tables in REVERSE order (to handle foreign keys)"
  STDERR.puts "=" * 80

  # Read all tables from the dump file using the shared iterator
  tables = []
  each_dump_line do |table, _data, _line_number|
    tables << table unless tables.include?(table)
  end

  STDERR.puts "Found #{tables.size} tables to truncate"
  STDERR.puts ""

  # Reverse the order to handle foreign key dependencies
  # Tables imported last should be truncated first
  tables.reverse!

  truncated_count = 0
  failed_count = 0

  tables.each do |table|
    begin
      STDERR.print "TRUNCATE: #{table}..."
      truncate_or_delete_table(table)
      STDERR.puts " ✓"
      truncated_count += 1
    rescue => e
      STDERR.puts " ✗"
      STDERR.puts "  -> Error: #{e.message}"
      failed_count += 1
    end
  end

  STDERR.puts ""
  STDERR.puts "=" * 80
  STDERR.puts "Truncate complete!"
  STDERR.puts "Truncated: #{truncated_count} tables"
  STDERR.puts "Failed: #{failed_count} tables"
end

def fix_all_sequences
  STDERR.puts "Fixing sequences for all tables..."
  STDERR.puts "=" * 80

  tables = get_tables_to_process

  fixed_count = 0
  failed_count = 0

  tables.each do |table|
    begin
      STDERR.print "Fixing sequence for #{table}..."
      fix_sequences(table)
      STDERR.puts ""
      fixed_count += 1
    rescue => e
      STDERR.puts " ✗"
      STDERR.puts "  -> Error: #{e.message}"
      failed_count += 1
    end
  end

  STDERR.puts ""
  STDERR.puts "=" * 80
  STDERR.puts "Fix sequences complete!"
  STDERR.puts "Fixed: #{fixed_count} tables"
  STDERR.puts "Failed: #{failed_count} tables"
end

# Main execution
command = ARGV[0]
# Truncate is ON by default, use --no-truncate to disable
truncate = !ARGV.include?('--no-truncate')

case command
when 'export'
  export_data
when 'import'
  import_data(truncate: truncate)
when 'truncate-all'
  truncate_all_tables
when 'fix-sequences'
  fix_all_sequences
else
  STDERR.puts "Usage:"
  STDERR.puts "  Export: bundle exec rails runner dump_data.rb export > data.jsonl"
  STDERR.puts "  Import: bundle exec rails runner dump_data.rb import [--no-truncate] < data.jsonl"
  STDERR.puts "  Truncate All: bundle exec rails runner dump_data.rb truncate-all < data.jsonl"
  STDERR.puts "  Fix Sequences: bundle exec rails runner dump_data.rb fix-sequences"
  STDERR.puts ""
  STDERR.puts "Commands:"
  STDERR.puts "  export           Export all data to stdout in JSONL format"
  STDERR.puts "  import           Import data from stdin in JSONL format"
  STDERR.puts "  truncate-all     Read dump file and truncate all tables in reverse order"
  STDERR.puts "  fix-sequences    Fix auto-increment sequences for all tables (Oracle/PostgreSQL/MySQL)"
  STDERR.puts ""
  STDERR.puts "Options:"
  STDERR.puts "  --no-truncate    Do NOT clear data from tables before importing (default: truncate enabled)"
  STDERR.puts ""
  STDERR.puts "Examples:"
  STDERR.puts "  # Export data"
  STDERR.puts "  bundle exec rails runner dump_data.rb export > data.jsonl"
  STDERR.puts ""
  STDERR.puts "  # Import and clear existing data first (DEFAULT)"
  STDERR.puts "  bundle exec rails runner dump_data.rb import < data.jsonl"
  STDERR.puts ""
  STDERR.puts "  # Import without clearing existing data"
  STDERR.puts "  bundle exec rails runner dump_data.rb import --no-truncate < data.jsonl"
  STDERR.puts ""
  STDERR.puts "  # Truncate all tables in reverse order before importing"
  STDERR.puts "  bundle exec rails runner dump_data.rb truncate-all < data.jsonl"
  STDERR.puts "  bundle exec rails runner dump_data.rb import --no-truncate < data.jsonl"
  STDERR.puts ""
  STDERR.puts "  # Fix all sequences after manual data manipulation"
  STDERR.puts "  bundle exec rails runner dump_data.rb fix-sequences"
  STDERR.puts ""
  STDERR.puts "  # Pipe directly between databases"
  STDERR.puts "  bundle exec rails runner dump_data.rb export | bundle exec rails runner dump_data.rb import"
  exit 1
end

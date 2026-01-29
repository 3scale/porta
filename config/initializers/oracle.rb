# frozen_string_literal: true

ActiveSupport.on_load(:active_record) do
  if System::Database.oracle?
    require 'arel/visitors/oracle12_hack' || next # once done, we can skip setup

    # in 6.0.6 automatic detection of max identifier length was introduced
    # see https://github.com/rsim/oracle-enhanced/pull/1703
    # but it was incomplete, proposed full fix is not merged yet
    # see https://github.com/rsim/oracle-enhanced/pull/2128
    # once it is merged, this should fail on remove_const so we will notice
    ActiveRecord::ConnectionAdapters::OracleEnhanced::DatabaseLimits.class_eval do
      remove_const(:IDENTIFIER_MAX_LENGTH)
      const_set(:IDENTIFIER_MAX_LENGTH, 128)
    end

    ENV['SCHEMA'] = 'db/oracle_schema.rb'
    Rails.configuration.active_record.schema_format = ActiveRecord.schema_format = :ruby

    ActiveRecord::ConnectionAdapters::TableDefinition.prepend(Module.new do
      def column(name, type, **options)
        # length parameter is not compatible with rails mysql/pg adapters:
        # rails expects it is limit in bytes, but oracle adapter expects it in number of characters
        # TODO: probably would be better to convert the byte limit to character limit
        if type == :integer
          super(name, type, **options.except(:limit))
        else
          super
        end
      end
    end)

    # clean-up prepared statements/cursors on connection return to pool
    module OracleStatementCleanup
      def self.included(base)
        base.set_callback :checkin, :after, :close_and_clear_statements
      end

      def close_and_clear_statements
        @statements&.clear
      end
    end

    ActiveRecord::Base.skip_callback(:update, :after, :enhanced_write_lobs)

    # For more information see https://github.com/rsim/oracle-enhanced/pull/2483
    module OracleEnhancedSmartQuoting
      SQL_UTF8_CHUNK_CHARS = 8191 # (32767÷4), 4 bytes max character; 1000 without MAX_STRING_SIZE=EXTENDED
      BLOB_INLINE_LIMIT = 16383 # (32767÷2) 2000 without MAX_STRING_SIZE=EXTENDED
      PLSQL_BASE64_CHUNK_SIZE = 24_573

      def quote(value)
        case value
        when ActiveModel::Type::Binary::Data
          data = value.to_s
          if data.empty?
            "empty_blob()"
          elsif data.bytesize <= BLOB_INLINE_LIMIT
            "to_blob(hextoraw('#{data.unpack1('H*')}'))"
          else
            quote_blob_as_subquery(data)
          end
        when ActiveRecord::Type::OracleEnhanced::Text::Data
          text = value.to_s
          text.empty? ? "empty_clob()" :
            value.to_s.scan(/.{1,#{SQL_UTF8_CHUNK_CHARS}}/m)
                 .map { |chunk| "to_clob('#{quote_string(chunk)}')" }
                 .join(" || ")
        else
          super
        end
      end

      # Generate a scalar subquery with PL/SQL function to build large BLOBs.
      # Uses DBMS_LOB.WRITEAPPEND with base64-encoded chunks for efficiency.
      # Testing showed hextoraw() unusable for being more than 100x slower.
      def quote_blob_as_subquery(data)
        out = +""
        out << "(\n"
        out << "  WITH FUNCTION make_blob RETURN BLOB IS\n"
        out << "    l_blob BLOB;\n"
        out << "  BEGIN\n"
        out << "    DBMS_LOB.CREATETEMPORARY(l_blob, TRUE, DBMS_LOB.CALL);\n"
        offset = 0
        while offset < data.bytesize
          chunk = data.byteslice(offset, PLSQL_BASE64_CHUNK_SIZE)
          out << "    DBMS_LOB.WRITEAPPEND(l_blob, "
          out << chunk.bytesize.to_s
          out << ", UTL_ENCODE.BASE64_DECODE(UTL_RAW.CAST_TO_RAW('"
          out << [chunk].pack("m0") # Base64 encoding without newlines
          out << "')));\n"
          offset += PLSQL_BASE64_CHUNK_SIZE
        end
        out << "    RETURN l_blob;\n"
        out << "  END;\n"
        out << "  SELECT make_blob() FROM dual\n"
        out << ")"
        out
      end
    end

    # this is also needed for inline quoting of large BLOBs work
    module OracleEnhancedSmartQuotingPreprocess
      # Add /*+ WITH_PLSQL */ hint for INSERT/UPDATE statements containing
      # PL/SQL function definitions. Oracle requires this hint for DML
      # statements that use PL/SQL in a WITH clause.
      # in Rails 8.0 this method was renamed to preprocess_query(sql)
      def transform_query(sql)
        sql = super
        if sql =~ /\A\s*(INSERT|UPDATE)\b(?=.*\bBEGIN\b)/im
          sql = sql.sub($1, "#{$1} /*+ WITH_PLSQL */")
        end
        sql
      end
    end

    ActiveRecord::ConnectionAdapters::OracleEnhanced::DatabaseStatements.prepend OracleEnhancedSmartQuotingPreprocess

    ActiveRecord::ConnectionAdapters::OracleEnhancedAdapter.class_eval do
      include OracleStatementCleanup
      prepend OracleEnhancedSmartQuoting

      # Fixing OCIError: ORA-01741: illegal zero-length identifier
      # because of https://github.com/rails/rails/commit/c18a95e38e9860953236aed94c1bfb877fa3be84
      # the value of `columns` is  [ "\"ACCOUNTS\".\"ID\"" ] which forms an incorrect query
      # ... OVER (PARTITION BY ["\"ACCOUNTS\".\"ID\""] ORDER BY "ACCOUNTS"."ID") ...
      # Will not be needed after https://github.com/rsim/oracle-enhanced/pull/2471 is merged and Rails upgraded
      def columns_for_distinct(columns, orders) # :nodoc:
        # construct a valid columns name for DISTINCT clause,
        # ie. one that includes the ORDER BY columns, using FIRST_VALUE such that
        # the inclusion of these columns doesn't invalidate the DISTINCT
        #
        # It does not construct DISTINCT clause. Just return column names for distinct.
        order_columns = orders.reject(&:blank?).map { |s|
          s = visitor.compile(s) unless s.is_a?(String)
          # remove any ASC/DESC modifiers
          s.gsub(/\s+(ASC|DESC)\s*?/i, "")
        }.reject(&:blank?).map.with_index { |column, i|
          "FIRST_VALUE(#{column}) OVER (PARTITION BY #{columns.join(', ')} ORDER BY #{column}) AS alias_#{i}__"
        }
        (order_columns << super).join(", ")
      end

      prepend(Module.new do
        # TODO: is this needed after
        # https://github.com/rsim/oracle-enhanced/commit/f76b6ef4edda72bddabab252177cb7f28d4418e2
        def add_column(table_name, column_name, type, **options)
          if type == :integer
            super(table_name, column_name, type, **options.except(:limit))
          else
            super
          end
        end

      end)
    end

    ActiveRecord::Relation.prepend(Module.new do
      # ar_object.with_lock doesn't work OOB on oracle, see https://github.com/rsim/oracle-enhanced/issues/2237
      # A workaround is to avoid using FETCH FIRST when reloading an object by primary key.
      # https://github.com/rails/rails/blob/v7.1.5.1/activerecord/lib/active_record/relation/finder_methods.rb#L506
      def find_one(id)
        if ActiveRecord::Base === id
          raise ArgumentError, <<-MSG.squish
            You are passing an instance of ActiveRecord::Base to `find`.
            Please pass the id of the object by calling `.id`.
          MSG
        end

        relation = if klass.composite_primary_key?
                     where(primary_key.zip(id).to_h)
                   else
                     where(primary_key => id)
                   end

        # this is the only change from the original method
        # original line:
        # record = relation.take
        record = relation.to_a.first

        raise_record_not_found_exception!(id, 0, 1) unless record

        record
      end
    end)

    BabySqueel::Nodes::Attribute.prepend(Module.new do
      # those relations are used in subqueries and oracle does not support ORDER in subqueries
      private def sanitize_relation(rel)
        super rel.unscope(:order)
      end
    end)

    ThinkingSphinx::ActiveRecord::SQLSource.prepend(Module.new do
      # If the Adapter is Oracle then we forcibly use ODBC client
      def type
        @type ||= case adapter
                  when ThinkingSphinx::ActiveRecord::DatabaseAdapters::OracleAdapter
                    'odbc'
                  else
                    super
                  end
      end
    end)

    ThinkingSphinx::ActiveRecord::DatabaseAdapters.module_eval do
      class << self
        prepend(Module.new do
          # https://github.com/pat/thinking-sphinx/blob/v3.2.0/lib/thinking_sphinx/active_record/database_adapters.rb#L35-L45
          # Adding a new DatabaseAdapters for ThinkingSphinx
          # This adds support for Oracle. OracleAdapter is responsible of query generation for Sphinx
          def adapter_for(model)
            return default.new(model) if default

            adapter = adapter_type_for(model)
            klass = case adapter
                    when :oracle
                      ThinkingSphinx::ActiveRecord::DatabaseAdapters::OracleAdapter
                    else
                      super
                    end
            klass.new model
          end

          # https://github.com/pat/thinking-sphinx/blob/v3.2.0/lib/thinking_sphinx/active_record/database_adapters.rb#L21-L33
          # This method is only needed for `adapter_for`
          # Part of freedom patch for ThinkingSphinx handling with Oracle
          def adapter_type_for(model)
            class_name = model.connection.class.name
            case class_name.split('::').last
            when /oracle/i
              :oracle
            else
              super
            end
          end
        end
        )
      end
    end

    ThinkingSphinx::Deltas::DatetimeDelta.prepend(Module.new do
      # https://github.com/pat/ts-datetime-delta/blob/v2.0.2/lib/thinking_sphinx/deltas/datetime_delta.rb#L167
      # A SQL condition (as part of the WHERE clause) that limits the result set to
      # just the delta data, or all data, depending on whether the toggled argument
      # is true or not. For datetime deltas, the former value is a check on the
      # delta column being within the threshold. In the latter's case, no condition
      # is needed, so nil is returned.
      def clause(*args)
        model = (args.length >= 2 ? args[0] : nil)
        is_delta = (args.length >= 2 ? args[1] : args[0]) || false

        table_name = (model.nil? ? adapter.quoted_table_name : model.quoted_table_name)
        column_name = (model.nil? ? adapter.quote(@column.to_s) : model.connection.quote_column_name(@column.to_s))

        if is_delta
          if adapter.class.name.downcase[/oracle/]
            "EXTRACT( day from ((#{table_name}.#{column_name} - SYSDATE) * 60 * 60 * 24)) + #{@threshold} > 0"
          else
            super
          end
        else
          nil
        end
      end
    end)

    ThinkingSphinx::ActiveRecord::SQLSource.prepend(Module.new do
      # This autogenerate the odbc_dsn string based on database.yml
      # For now it is only particular to our project, later we could extract it and make a PR to the upstream project
      def set_database_settings(settings)
        super
        conf = System::Database.database_config.configuration_hash
        if type == 'odbc'
          @odbc_dsn ||= "DSN=oracle;Driver={Oracle-Driver};Dbq=#{conf[:host]}:#{conf[:port] || 1521}/#{conf[:database]};Uid=#{conf[:username]};Pwd=#{conf[:password]}"
        end
      end
    end)

    ActiveRecord::ConnectionAdapters::OracleEnhanced::SchemaStatements.module_eval do
      def add_index(table_name, column_name, **options) #:nodoc:
        # All this code is exactly the same as the original except the line of the ALTER TABLE, which adds an additional USING INDEX #{quote_column_name(index_name)}
        # The reason of this is otherwise it picks the first index that finds that contains that column name, even if it is shared with other columns and it is not unique.
        # upstreamed: https://github.com/rsim/oracle-enhanced/pull/2293
        index_name, index_type, quoted_column_names, tablespace, index_options = add_index_options(table_name, column_name, **options)
        quoted_table_name = quote_table_name(table_name)
        quoted_column_name = quote_column_name(index_name)
        execute "CREATE #{index_type} INDEX #{quoted_column_name} ON #{quoted_table_name} (#{quoted_column_names})#{tablespace} #{index_options}"
        if index_type == 'UNIQUE' && quoted_column_names !~ /\(.*\)/
          execute "ALTER TABLE #{quoted_table_name} ADD CONSTRAINT #{quoted_column_name} #{index_type} (#{quoted_column_names}) USING INDEX #{quoted_column_name}"
        end
      end

      def distinct_relation_for_primary_key(relation) # :nodoc:
        primary_key_columns = Array(relation.primary_key).map do |column|
          visitor.compile(relation.table[column])
        end

        values = columns_for_distinct(
          primary_key_columns,
          relation.order_values
        )

        limited = relation.reselect(values).distinct!

        # The original code in https://github.com/rails/rails/blob/v7.1.5.1/activerecord/lib/active_record/connection_adapters/abstract/schema_statements.rb#L1404-L1406
        # ----
        # limited_ids = select_rows(limited.arel, "SQL").map do |results|
        #   results.last(Array(relation.primary_key).length) # ignores order values for MySQL and PostgreSQL
        # end
        # ----
        # The change is needed because in Oracle, because otherwise the resulting `limited_ids` array would be wrong. For example,
        # for a ServiceContract model that has the primary key "id" and a query with ordering and filtering you may get:
        # 1. `limited` variable can be something like: #<ActiveRecord::Relation [#<ServiceContract alias_0__: "live", id: 4, raw_rnum_: 1>]>
        # 2. `select_rows` would then return [["live",4,1]]
        # 3. `limited_ids` calculation will result in [[1]], which is an invalid IDs list (the expected is [[4]])
        # The updated code doesn't make assumptions about how many columns are selected or their order, but fetches the values according
        # to the primary key column names
        limited_ids = select_all(limited.arel, "SQL").to_ary.map do |result|
          result.values_at(*Array(relation.primary_key))
        end

        if limited_ids.empty?
          relation.none!
        else
          relation.where!(**Array(relation.primary_key).zip(limited_ids.transpose).to_h)
        end

        relation.limit_value = relation.offset_value = nil
        relation
      end
    end

    # see https://github.com/rsim/oracle-enhanced/issues/2276
    module OracleEnhancedAdapterSchemaIssue2276
      def column_definitions(table_name)
        deleted_object_id = prepared_statements_disabled_cache.delete(object_id)
        super
      ensure
        prepared_statements_disabled_cache.add(deleted_object_id) if deleted_object_id
      end
    end

    ActiveRecord::ConnectionAdapters::OracleEnhancedAdapter.prepend OracleEnhancedAdapterSchemaIssue2276

    # see https://github.com/kubo/ruby-oci8/pull/271
    module OCI8DisableArrayFetch
      private

      def define_one_column(pos, param)
        @fetch_array_size = nil # disable memory array fetching anytime
        super # call original
      end
    end

    OCI8::Cursor.prepend(OCI8DisableArrayFetch)

    # see https://github.com/kubo/ruby-oci8/pull/271
    # Enable piecewise retrieval for both CLOBs and BLOBs
    # With the OCIConnectionCursorLobFix above, we can safely use both mappings
    # because LOBs are bound as OCI8::CLOB/BLOB objects, not LONG data
    # Note: disable temporary for issues with NLS_LANG=AMERICAN_AMERICA.UTF8
    # OCI8::BindType::Mapping[:clob] = OCI8::BindType::Long
    # OCI8::BindType::Mapping[:blob] = OCI8::BindType::LongRaw
  end
end

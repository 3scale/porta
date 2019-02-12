class ThinkingSphinx::ActiveRecord::DatabaseAdapters::OracleAdapter <
  ThinkingSphinx::ActiveRecord::DatabaseAdapters::AbstractAdapter

  def boolean_value(value)
    value ? '1' : '0'
  end

  def cast_to_bigint(clause)
    "CAST(#{clause} AS NUMBER(38))"
  end

  def cast_to_string(clause)
    "CAST(#{clause} AS CHAR)"
  end

  def cast_to_timestamp(clause)
    "TO_NUMBER((#{clause} - to_date('19700101', 'YYYYMMDD')) * 24 * 60 * 60)"
  end

  # Equivalent of CONCAT_WS in mysql
  def concatenate(clause, separator = ' ')
    clause.split(', ').collect { |part|
      convert_nulls(part, "''")
    }.join(" || '#{separator}' || ")
  end

  def convert_nulls(clause, default = '')
    "COALESCE(#{clause}, #{default})"
  end

  def convert_blank(clause, default = '')
    "COALESCE(NULLIF(#{clause}, ''), #{default})"
  end

  # Equivalent of GROUP_CONCAT in mysql
  def group_concatenate(clause, separator = ' ')
    "LISTAGG(#{clause}, '#{separator}') WITHIN GROUP (ORDER BY #{clause})"
  end

  def time_zone_query_pre
    ["ALTER SESSION SET TIME_ZONE='UTC'"]
  end

  # It is ruled by environment NLS_LANG
  def utf8_query_pre
    []
  end

end

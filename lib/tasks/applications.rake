# frozen_string_literal: true

require "system/database/#{System::Database.adapter}"

namespace :applications do
  desc 'Recreate cinstances table without the column end_user_required'
  task :recreate_table_without_column_end_user_required => :environment do
    return unless System::Database.mysql?
    CinstancesTableRecreator.new.call('end_user_required')
  end

  class CinstancesTableRecreator
    attr_reader :undesired_columns

    def call(*undesired_columns)
      @undesired_columns = undesired_columns

      # TODO: in a transaction?
      # TODO: ensure that it works, with the right order :)
      # TODO: monitor progress

      create_new_table
      insert_cinstances_data_into_new_table
      drop_old_table
      rename_new_table
      # recreate_triggers
      # recreate_indices
    end

    # def recreate_indices
    #   db_connection.indexes('cinstances').each do |index|
    #     create_index_sql = <<-SQL.strip_heredoc
    #       CREATE#{' UNIQUE' if index.unique} INDEX #{index.name}
    #       ON cinstances (#{index.columns.join(', ')})
    #     SQL
    #     db_connection.execute(create_index_sql)
    #   end
    # end

    # def recreate_triggers
    #   # TODO: update tenant_id ?
    #   System::Database.triggers.each do |trigger|
    #     next if trigger.table != 'cinstances'
    #     db_connection.execute(trigger.create) # TODO: create or recreate or what?
    #   end
    # end

    def insert_cinstances_data_into_new_table
      desired_columns = db_connection.columns('cinstances').each_with_object([]) do |column, columns|
        column_name = column.name
        columns << column_name unless undesired_columns.include?(column_name)
      end.join(', ')

      insert_sql = <<-SQL.strip_heredoc
        INSERT INTO cinstances_new(#{desired_columns})
        SELECT #{desired_columns}
        FROM cinstances;
      SQL

      db_connection.execute(insert_sql)
    end

    def create_new_table
      db_connection.execute('CREATE TABLE cinstances_new LIKE cinstances;')

      drop_column_sql = undesired_columns.inject('ALTER TABLE cinstances_new') do |sql, column|
        sql + "\nDROP COLUMN #{column},"
      end.chomp(',') + ';'
      db_connection.execute(drop_column_sql)
    end

    def drop_old_table
      db_connection.execute('DROP TABLE cinstances;')
    end

    def rename_new_table
      db_connection.execute('RENAME TABLE cinstances_new TO cinstances;')
    end

    def db_connection
      @connection ||= ActiveRecord::Base.connection
    end
  end
end

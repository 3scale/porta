class MoveLiquidPagesOverToDynamicViews < ActiveRecord::Migration
  def self.up
    execute('INSERT INTO dynamic_views (
               version,
               type,
               name,
               handler,
               body,
               created_at,
               updated_at,
               account_id)
             SELECT
               1,
               "PageTemplate",
               title,
               "liquid",
               content,
               created_at,
               updated_at,
               account_id
             FROM liquid_pages')

    # Do this the simple way, just copy the record into the first version and
    # forget the rest.
    execute('INSERT INTO dynamic_view_versions (
               dynamic_view_id,
               version,
               type,
               name,
               handler,
               body,
               created_at,
               updated_at,
               account_id)
             SELECT
               id,
               1,
               "PageTemplate",
               name,
               "liquid",
               body,
               created_at,
               updated_at,
               account_id
             FROM dynamic_views')

    drop_table :liquid_pages
    drop_table :liquid_page_versions;
  end

  def self.down
    create_table :liquid_pages do |table|
      table.integer :account_id
      table.string  :title
      table.text    :content
      table.integer :version
      table.timestamps
    end

    create_table :liquid_page_versions do |table|
      table.integer :liquid_page_id
      table.integer :version
      table.integer :account_id
      table.string  :title
      table.text    :content
      table.timestamps
    end

    execute('INSERT INTO liquid_pages (
               account_id,
               title,
               content,
               version)
             SELECT
               account_id,
               name,
               body,
               1
             FROM dynamic_views
             WHERE type = "PageTemplate" AND account_id IS NOT NULL')

    execute('INSERT INTO liquid_page_versions (
               id,
               version,
               account_id,
               title,
               content,
               created_at,
               updated_at)
             SELECT
               id,
               1,
               account_id,
               title,
               content,
               created_at,
               updated_at
             FROM liquid_pages')

    execute('DELETE FROM dynamic_views WHERE type = "PageTemplate" AND account_id IS NOT NULL')
  end
end

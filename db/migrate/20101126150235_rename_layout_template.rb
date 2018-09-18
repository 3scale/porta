class RenameLayoutTemplate < ActiveRecord::Migration
  def self.up
    execute('UPDATE dynamic_views         SET name = "main_layout" WHERE name = "layout"')
    execute('UPDATE dynamic_view_versions SET name = "main_layout" WHERE name = "layout"')

    # Kill master's layout.
    execute('DELETE dynamic_views FROM dynamic_views INNER JOIN accounts ON accounts.id = dynamic_views.account_id WHERE dynamic_views.name = "main_layout" AND accounts.master')
  end

  def self.down
    execute('UPDATE dynamic_views         SET name = "layout" WHERE name = "main_layout"')
    execute('UPDATE dynamic_view_versions SET name = "layout" WHERE name = "main_layout"')
  end
end

class AddUniqueIndexToConnectors < ActiveRecord::Migration
  def self.up
    rslt = execute "select page_id, page_version, connectable_id, connectable_version, connectable_type, container, min(id)  from connectors group by page_id, page_version, connectable_id, connectable_version, connectable_type, container having count(*) > 1;"
    rslt.each do |row|
      unless row[3].nil?
        execute "DELETE FROM connectors WHERE page_id = #{row[0]} AND page_version = #{row[1]} AND connectable_id = #{row[2]} AND connectable_version = #{row[3]} AND connectable_type = '#{row[4]}' AND container = '#{row[5]}' AND id > #{row[6]}"
      else
        execute "DELETE FROM connectors WHERE page_id = #{row[0]} AND page_version = #{row[1]} AND connectable_id = #{row[2]} AND connectable_version IS NULL AND connectable_type = '#{row[4]}' AND container = '#{row[5]}' AND id > #{row[6]}"
      end
    end
    # FIXME: unfortunately we cant correlate deletes in mysql and doing this join in big tables is uber slow
    #execute "DELETE c1 FROM connectors c1 JOIN connectors c2 ON c2.page_id = c1.page_id AND c2.page_version = c1.page_version AND c2.connectable_id = c1.connectable_id AND c2.connectable_version = c1.connectable_version AND c2.container = c1.container AND c2.id < c1.id"
    execute "CREATE UNIQUE INDEX unique_connector ON connectors (page_id, page_version, connectable_id, connectable_version, connectable_type, container)"
  end

  def self.down
    execute "DROP INDEX unique_connector ON connectors"
  end
end

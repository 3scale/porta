class SetHugeLimitOnHtmlBlockBody < ActiveRecord::Migration
  def self.up
    change_table :html_blocks do |t|
      t.change :content, :text, :limit => 2147483647
    end

    change_table :html_block_versions do |t|
      t.change :content, :text, :limit => 2147483647
    end
  end
end

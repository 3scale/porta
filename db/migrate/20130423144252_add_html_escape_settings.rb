class AddHtmlEscapeSettings < ActiveRecord::Migration
  def change
    change_table :settings do |t|
      t.boolean :cms_escape_draft_html, :cms_escape_published_html, null: false, default: false
    end
  end
end

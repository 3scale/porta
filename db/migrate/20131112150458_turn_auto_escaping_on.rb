class TurnAutoEscapingOn < ActiveRecord::Migration
  def up
    change_column_default :settings, :cms_escape_draft_html, true
    change_column_default :settings, :cms_escape_published_html, true
  end

  def down
    change_column_default :settings, :cms_escape_draft_html, false
    change_column_default :settings, :cms_escape_published_html, false
  end
end

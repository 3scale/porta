class BackfillTitlesCMSSections < ActiveRecord::Migration[5.2]
  def up
    CMS::Section.unscoped.where(title: ['', nil]).update_all("title = system_name")
  end
end

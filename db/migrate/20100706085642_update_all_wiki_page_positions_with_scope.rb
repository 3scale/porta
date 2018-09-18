class UpdateAllWikiPagePositionsWithScope < ActiveRecord::Migration

  def self.up
    Account.all.each do |account|
      puts "Account##{account.id}"
      account.wiki_pages.find(:all, :order => "title ASC").each_with_index do |wiki_page, index|
        wiki_page.update_attributes :position => (index + 1)
      end
    end
  end

  def self.down
    # Nothing to do ...
  end

end


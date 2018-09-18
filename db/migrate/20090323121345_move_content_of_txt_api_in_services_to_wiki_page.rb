class MoveContentOfTxtApiInServicesToWikiPage < ActiveRecord::Migration
  def self.up
    # Move api to wiki page named home
    execute('INSERT INTO wiki_pages (account_id, title, content, created_at, updated_at)
             SELECT services.account_id, "Home", services.txt_api, NOW(), NOW()
             FROM services INNER JOIN accounts ON accounts.id = services.account_id
             WHERE accounts.domain IS NOT NULL AND services.parent_id IS NULL')

    # Delete api in services             
    execute('UPDATE services INNER JOIN accounts ON accounts.id = services.account_id
             SET services.txt_api = NULL
             WHERE accounts.domain IS NOT NULL')

    # Generate slugs for wikis             
    system('rake friendly_id:make_slugs MODEL=WikiPage')             
  end

  def self.down
    execute('UPDATE services INNER JOIN accounts ON accounts.id = services.account_id
                             INNER JOIN wiki_pages ON wiki_pages.account_id = accounts.id
             SET services.txt_api = wiki_pages.content
             WHERE wiki_pages.title = "Home"')

    execute('DELETE FROM wiki_pages WHERE wiki_pages.title = "Home"')
    execute('DELETE FROM slugs WHERE sluggable_type = "WikiPage" AND name = "home"')
  end
end

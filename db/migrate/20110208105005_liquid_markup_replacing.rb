require 'app/models/account'

class LiquidMarkupReplacing < ActiveRecord::Migration
  def self.up
    #PageTemplate.find_all_by_name('main_layout').each do |page|
    #  class << page
    #    def save!(perform_validations=false)
    #      save(perform_validations) || raise(ActiveRecord::RecordNotSaved.new(errors.full_messages))
    #    end
    #  end

    #  page.body.gsub!(/\{\%\s*if\s*page_title\s*==\s*'Forum'\s*\%\}\n*\{\{\s*'forum.css'\s*\|\s*stylesheet_link_tag\s*\}\}\n*\s*\{\%\s*endif\s*\%\}/, '')
    #  page.body.gsub!(/\{\{\s*page.company_name\s*\}\}/, "{{ site_account.name }}")
    #  page.body.gsub!(/\{\{\s*\'whitelabel.css\'\s*\|\s*stylesheet_link_tag\s*\}\}/, "")

    #  page.body.gsub!(/\{\{\s*\"cms\/3scale.css\"\s*\|\s*stylesheet_link_tag\s*\}\}/, "")
    #  page.body.gsub!(/\{\{\s*\"components\/all.css\"\s*\|\s*stylesheet_link_tag\s*\}\}/, "")
    #  page.body.gsub!(/\{\%\s*container\s*sidebar\s*\%\}/, "")

    #  account = begin
    #    Account.find(page.account_id)
    #  rescue; end
    #  unless account.nil?
    #    unless account.master?
    #      page.body.gsub!(/\<head\>/, "<head>\n{{ \"connect\/styles.css\" | stylesheet_link_tag }}")
    #    end
    #  end
    #  page.save!

    #  puts "Parsed page #{page.id}"
    #end
  end

  def self.down
  end
end


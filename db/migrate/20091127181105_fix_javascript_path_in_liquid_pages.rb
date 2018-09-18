class FixJavascriptPathInLiquidPages < ActiveRecord::Migration
  def self.up
    LiquidPage.all.each do |page|
      new_content = page.content.gsub(/<script.*?whitelabel\/behaviours\.js.*?>.*?<\/script>/, '')

      page.content = new_content
      page.save!
    end
  end

  def self.down
  end
end

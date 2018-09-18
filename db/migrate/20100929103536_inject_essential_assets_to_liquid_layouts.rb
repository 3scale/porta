class InjectEssentialAssetsToLiquidLayouts < ActiveRecord::Migration
  def self.up
    pages = LiquidPage.find_all_by_title('layout')
    pages.each do |page|
      puts "Hacking layout of: #{page.account.try!(:org_name)}"

      body = page.content
      # Adds essential assets tag

      essential_assets_re = /\{\{\s*essential_assets\s*\}\}/

      unless body =~ essential_assets_re
        body.sub!(/<meta\s+http\-equiv\s*=\s*"Content-Type".*>/i, "\\0\n\n  {{ essential_assets }}")
        body.sub!(/<head.*>/, "\\0\n\n  {{ essential_assets }}") unless body =~ essential_assets_re
      end

      # Removes old js
      urls = [
        'http://ajax.googleapis.com/ajax/libs/prototype/1/prototype.js',
        'http://ajax.googleapis.com/ajax/libs/scriptaculous/1/scriptaculous.js',
        'http://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js',
        'lowpro',
        'swfobject',
        'highlight.pack',
        'application',
        'ajax_upload',
        'popup_link',
        'chart_controls',
        'behaviours',
        '/prototip/js/prototip2']

      urls.each do |url|
        body.gsub!(/\s*{{\s*'\s*#{Regexp.quote(url)}\s*'\s*\|\s*javascript_include_tag\s*}}\s*/, '')
      end

      urls = [
        '/javascripts/prototype.js',
        '/javascripts/effects.js',
        '/javascripts/dragdrop.js',
        '/javascripts/controls.js',
        '/javascripts/lowpro.js',
        '/javascripts/swfobject.js',
        '/javascripts/highlight.pack.js',
        '/javascripts/application.js',
        '/javascripts/ajax_upload.js',
        '/javascripts/popup_link.js',
        '/javascripts/chart_controls.js',
        '/javascripts/behaviours.js']

      urls.each do |url|
        body.gsub!(/\s*<script\s*src="#{Regexp.quote(url)}".*>\s*<\/script>\s*/, '')
      end

      page.reload # XXX: No idea why, but without reload, the change does not get written
      page.update_attribute(:content, body)
    end
  end

  def self.down
    raise ActiveRecord::IrreversableMigration
  end
end

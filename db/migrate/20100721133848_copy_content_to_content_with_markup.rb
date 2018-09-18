class CopyContentToContentWithMarkup < ActiveRecord::Migration
  def self.up
    #HtmlBlock.all.each do |h|
    #  h.versions.each do | hv |
    #    execute "update html_block_versions set content_with_markup=#{HtmlBlock.connection.quote(hv.content)} where id=#{hv.id}" if hv.content_with_markup.blank?
    #  end
    #  execute "update html_blocks set content_with_markup=#{HtmlBlock.connection.quote(h.content)} where id=#{h.id}" if h.content_with_markup.blank?
    #end

    #BlogPost.all.each do |h|
    #  h.versions.each do | hv |
    #    execute "update blog_post_versions set content_with_markup=#{BlogPost.connection.quote(hv.body)} where id=#{hv.id}" if hv.content_with_markup.blank?

    #  end
    #  execute "update blog_posts set content_with_markup=#{BlogPost.connection.quote(h.body)} where id=#{h.id}" if h.content_with_markup.blank?
    #end
  end

  def self.down
  end
end

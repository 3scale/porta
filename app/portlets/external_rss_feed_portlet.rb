require 'open-uri'

class ExternalRssFeedPortlet < CMS::Portlet::Base
  attributes :url_feed
  attr_accessible :url_feed

  validates_presence_of :url_feed


  def self.default_template
<<EOF
<style scoped>
  .title h2 {font-size: 21px;}
</style>

<h1>Developer Blog</h1>
{% for post in posts limit:4 %}
  <div class="post">
    <div class="title"><h2><a href="{{ post.link }}">{{ post.title }}</a></h2></div>
    <hr/>
    <div class="description">{{ post.description }}</div>
  </div>
{% endfor %}
EOF
  end

  def assigns_for_liquid
    cache(:assigns) do
      {:posts => posts}
    end
  end

  private

  def posts
    begin

      doc = Rails.cache.fetch(url_feed, :expires_in => 10.minutes) do
        Rails.logger.debug "Requesting fresh version of #{url_feed}"
        open(url_feed).read
      end
      # Rails.logger.debug "Displaying cached version from (#{self.last_update}) of #{self.class}:#{id}"

      Nokogiri::XML(doc).xpath('//item').map do |p|
        { :title => p.xpath('title').inner_text, :link => p.xpath('link ').inner_text,
          :description => p.xpath('description').inner_text }.stringify_keys
      end
    rescue
      Rails.logger.error "Exception happened when fetching RSS: #{$!}"
      Rails.logger.debug "Backtrace: #{$!.backtrace.join("\n")}"

      []
    end
  end

end

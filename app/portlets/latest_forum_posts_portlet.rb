class LatestForumPostsPortlet < CMS::Portlet::Base
  attributes :posts
  attr_accessible :posts

  validates_numericality_of :posts

  def self.default_template
<<END
<div class="promo promoForum">
  <h3>Forum</h3>
  <p>All the latest straight from the 3scale development forum</p>
  {% for post in posts %}
    <li>
      {{ post | to_post_link }}
      <p>{{ post | to_post_date }}</p>
    </li>
  {% endfor %}
</div>
END
  end

  def assigns_for_liquid
    cache(:assigns) do
      posts = forum_posts.collect do |post|
        post.class.send(:include, ToLiquid)
        post.to_liquid
      end
      { :posts => posts }
    end
  end

  def liquid_options
    { :filters => Helper }
  end


  protected

  def forum_posts
    provider.forum.posts.all(:order => 'updated_at DESC',
                             :limit => posts,
                             :include => :topic)
  end

  module ToLiquid
    include DeveloperPortal::Engine.routes.url_helpers
    include ActionView::Helpers::DateHelper

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def default_url_options
        {}
      end
    end

    def default_url_options
      {}
    end

    def to_liquid

      { :topic_id => topic.id,
        :topic_path => forum_topic_path(topic),
        :topic_title => topic.title,
        :created_at_in_words => distance_of_time_in_words_to_now(created_at) }.stringify_keys
    end
  end

  module Helper
    include Liquid::Filters::RailsHelpers

    def to_post_date(post)
      post['created_at_in_words']
    end

    def to_post_link(post)
      link_to truncate(post['topic_title']), post['topic_path']
    end
  end
end

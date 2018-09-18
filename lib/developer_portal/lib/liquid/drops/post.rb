module Liquid
  module Drops
    class Post < Drops::Model
      allowed_name :post

      # TODO: describe if it is escaped
      desc "Text of the post."
      def body
        @model.body
      end

      desc "Every post belongs to a [topic](#topic-drop)."
      def topic
        ::Liquid::Drops::Topic.new(@model.topic)
      end

      desc "Date when this post created."
      example %{
       {{ post.created_at | date: i18n.short_date }}
      }
      def created_at
        @model.created_at
      end

      desc "The URL of this post within its topic."
      def url
        system_url_helpers.forum_topic_path(@model.topic, anchor: "post_#{@model.id}")
      end
    end
  end
end

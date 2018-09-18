module Liquid
  module Drops
    class Topic < Drops::Model
      allowed_name :topic

      # TODO: describe if it is escaped
      desc "Name of the topic. Submitted when first post to the thread is posted."
      def title
        @model.title
      end

      def url
        Rails.application.routes.url_helpers.forum_topic_path(@model)
      end
    end
  end
end

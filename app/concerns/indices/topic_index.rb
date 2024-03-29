# frozen_string_literal: true

module Indices
  module TopicIndex
    extend ActiveSupport::Concern

    included do
      after_commit :index_object
    end

    def sphinx_post_bodies
      posts.pluck(:body).join(' ').to_s[0...8_000_000]
    end

    module ForPost
      extend ActiveSupport::Concern

      included do
        # for all changes including destroy
        after_commit :index_topic
      end

      protected

      def index_topic
        return unless allow_system_indexation?

        SphinxIndexationWorker.perform_later(topic.class, topic.id)
      end

      def allow_system_indexation?
        !System::Database.oracle?
      end
    end

    protected

    def index_object
      return unless allow_system_indexation?

      SphinxIndexationWorker.perform_later(self.class, id)
    end

    def allow_system_indexation?
      !System::Database.oracle?
    end
  end
end

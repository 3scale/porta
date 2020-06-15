# frozen_string_literal: true

unless System::Database.oracle?
  ThinkingSphinx::Index.define(:topic, with: :real_time) do
    indexes :title
    indexes sphinx_post_bodies, as: :post

    has :tenant_id, type: :integer

    has :forum_id, type: :integer
    has :sticky, type: :boolean
    has :last_updated_at, type: :timestamp

    scope { Topic.includes(:posts) }
  end
end

module TopicIndex
  extend ActiveSupport::Concern

  included do
    after_save :sphinx_index
  end

  def sphinx_post_bodies
    posts.pluck(:body).join(" ")
  end

  module ForPost
    extend ActiveSupport::Concern

    included do
      after_save :index_topic
      after_destroy :index_topic
    end

    protected

    def index_topic
      return if System::Database.oracle?

      SphinxIndexationWorker.perform_later(topic)
    end
  end

  protected

  def sphinx_index
    return if System::Database.oracle?

    SphinxIndexationWorker.perform_later(self)
  end
end

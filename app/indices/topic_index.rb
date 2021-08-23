# frozen_string_literal: true

module TopicIndex
  extend ActiveSupport::Concern

  included do
    after_save :sphinx_index
  end

  def sphinx_post_bodies
    posts.pluck(:body).join(' ').to_s[0...8_000_000]
  end

  module ForPost
    extend ActiveSupport::Concern

    included do
      after_save :index_topic
      after_destroy :index_topic
    end

    protected

    def index_topic
      return unless allow_system_indexation?

      SphinxIndexationWorker.perform_later(topic)
    end

    def allow_system_indexation?
      !System::Database.oracle? &&
        ThinkingSphinx::Configuration.new.settings['indexed_models'].include?('Topic')
    end
  end

  protected

  def sphinx_index
    return unless allow_system_indexation?

    SphinxIndexationWorker.perform_later(self)
  end

  def allow_system_indexation?
    !System::Database.oracle? &&
      ThinkingSphinx::Configuration.new.settings['indexed_models'].include?('Topic')
  end
end

unless System::Database.oracle?
  ThinkingSphinx::Index.define(:topic, with: :real_time) do
    indexes :title
    indexes sphinx_post_bodies, as: :post

    has :tenant_id, type: :bigint

    has :forum_id, type: :bigint
    has :sticky, type: :boolean
    has :last_updated_at, type: :timestamp

    scope { Topic.includes(:posts) }
  end
end

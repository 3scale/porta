# frozen_string_literal: true

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

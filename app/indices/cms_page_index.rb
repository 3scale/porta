# frozen_string_literal: true

ThinkingSphinx::Index.define 'cms/page', with: :real_time do
  indexes :title
  has :tenant_id, type: :bigint

  indexes :published
  scope { CMS::Page.where(searchable: true) }
end

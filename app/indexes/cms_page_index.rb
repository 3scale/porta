# frozen_string_literal: true

ThinkingSphinx::Index.define('cms/page'.to_sym, with: :real_time) do
  # Fields
  indexes title

  # Attributes
  has tenant_id, type: :bigint

  indexes :published
  scope { CMS::Page.where(searchable: true) }
end

module CMSPageIndex
end

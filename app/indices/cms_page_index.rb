# frozen_string_literal: true

module CMSPageIndex
  extend ActiveSupport::Concern

  included do
    after_save :sphinx_index
  end

  protected

  def sphinx_index
    return unless searchable?

    SphinxIndexationWorker.perform_later(self)
  end
end

ThinkingSphinx::Index.define 'cms/page', with: :real_time do
  indexes :title
  has :tenant_id, type: :bigint

  indexes :published
  scope { CMS::Page.where(searchable: true) }
end

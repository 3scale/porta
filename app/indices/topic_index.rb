ThinkingSphinx::Index.define(:topic,
                             with: :active_record,
                             delta: ThinkingSphinx::Deltas::DatetimeDelta,
                             delta_options: {
                               threshold: SPHINX_DELTA_INTERVAL,
                               column: :last_updated_at
                             }) do
  indexes :title
  indexes posts.body, as: 'post'

  has :tenant_id

  has :forum_id
  has :sticky
  has :last_updated_at
end

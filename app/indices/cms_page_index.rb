ThinkingSphinx::Index.define 'cms/page', with: :active_record do
  indexes :title
  has :tenant_id
  where sanitize_sql(['searchable=?', true])

  # FIXME: not truncating the published character size to 32k
  # Oracle limits the size of VARCHAR2 to 32k in extended mode
  if System::Database.oracle?
    indexes 'TO_CHAR("CMS_TEMPLATES"."PUBLISHED")', as: :published, type: :string
    group_by 'TO_CHAR("CMS_TEMPLATES"."PUBLISHED")'
  else
    indexes :published
  end

  set_property sql_range_step: 1_024
end

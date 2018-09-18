class CMS::Template::Version < ApplicationRecord
  self.table_name = :cms_templates_versions
  belongs_to :template, :polymorphic => true

  validates :type, :path, :title, :system_name, :content_type, :template_type,
            :updated_by, :handler, length: { maximum: 255 }
  validates :published, :draft, length: { maximum: 16777215 }
  validates :options, length: { maximum: 65535 }

  scope :published, -> { where(:published) }

  def self.versioned_column?(name)
    column_names.include?(name.to_s)
  end

  def state
    case
    when draft.present?
        :draft
    when draft.nil? && published.present?
        :published
    end
  end

  def current
    state && send(state)
  end

  def diff(other)
    ThreeScale::Diff.new(current, other.current)
  end

  def revert_attributes
    accessible = template.class.accessible_attributes.delete('draft').add('updated_at').add('updated_by')

    accessible << state.to_s
    attributes.slice *accessible
  end

end

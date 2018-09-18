class CMS::LegalTerm < ApplicationRecord

  validates :name, :slug, length: { maximum: 255 }
  validates :body, length: { maximum: 4294967295 }

  def set_rails_view_path
  end
end

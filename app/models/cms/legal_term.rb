# This was created in the past to accommodate legacy rake tasks that no more exist.
# I don't think any objects were created ever. Need to remove the model when convenient.
class CMS::LegalTerm < ApplicationRecord

  validates :name, :slug, length: { maximum: 255 }
  validates :body, length: { maximum: 4294967295 }

  def set_rails_view_path
  end
end

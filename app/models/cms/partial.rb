class CMS::Partial < CMS::Template
  self.search_type = 'partial'

  validates :system_name, presence: true
  validate :system_name_rules

  has_data_tag :partial

  def system_name_rules
    if CMS::Builtin::Partial.system_name_whitelist.include?(system_name) ||
        CMS::Builtin::LegalTerm.system_name_whitelist.include?(system_name)
      errors.add(:system_name, :reserved)
    end
  end

  def search
    super.merge string: "#{system_name}"
  end

  def content_type
    'text/html'
  end
end

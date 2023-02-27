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

  def to_xml(options = {})
    xml = options[:builder] || Nokogiri::XML::Builder.new

    xml.__send__(self.class.data_tag) do |x|
      unless new_record?
        xml.id id
        xml.created_at created_at.xmlschema
        xml.updated_at updated_at.xmlschema
      end
      x.system_name system_name
      unless options[:short]
        x.draft { |node| node.cdata draft }
        x.published { |node| node.cdata published }
      end
    end

    xml.to_xml
  end

  def content_type
    'text/html'
  end
end

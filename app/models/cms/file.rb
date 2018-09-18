class CMS::File < ApplicationRecord
  include CMS::Filtering
  include NormalizePathAttribute
  acts_as_taggable

  attr_accessible :provider, :section, :path, :attachment, :downloadable, :tag_list

  delegate :s3_provider_prefix, to: :provider

  self.table_name = :cms_files

  belongs_to :section,  class_name: 'CMS::Section', touch: true
  belongs_to :provider, class_name: 'Account'

  has_attached_file :attachment,
                    url: Rails.application.config.cms_files_path,
                    s3_url_options: ->(file) { file.s3_url_options }

  verify_path_format :path
  validates :path, :section, :provider, presence: true

  validates_attachment :attachment, presence: true
  do_not_validate_attachment_file_type :attachment

  validates :path, uniqueness: { :scope => :provider_id }, length: { maximum: 255 }
  validates :attachment_content_type, :attachment_file_name, :random_secret, :name,
            length: { maximum: 255 }

  before_save :generate_random_secret

  delegate :accessible_by?, :public?, :protected?, :to => :section, :allow_nil => true

  # this fixes bug, when files with non ascii characters couldn't be uploaded
  before_save do |file|
    file.attachment.extend(UTF8Attachment) if defined?(::Encoding)
  end

  module UTF8Attachment
    def original_filename
      super.tap do |filename|
        filename.force_encoding(Encoding.default_external)
      end
    end
  end

  alias_attribute :name, :attachment_file_name
  alias_attribute :title, :attachment_file_name

  def to_xml(options = {})
    xml = options[:builder] || Nokogiri::XML::Builder.new

    xml.file do |x|
      unless new_record?
        xml.id id
        xml.created_at created_at.xmlschema
        xml.updated_at updated_at.xmlschema
      end
      x.section_id section_id
      x.path path
      x.url url.to_s
      x.tag_list tag_list
      x.title title
    end

    xml.to_xml
  end

  def redirect?
    attachment.options[:storage] == :s3
  end

  def path=(value)
    value = value.prepend('/') if value && !value.start_with?('/')
    super
  end

  def is_image?
    attachment.content_type =~ /image/
  end

  def dirty?
    false
  end

  def disposition
    downloadable? ? :attachment : :inline
  end

  def url(expires: nil, **options)
    if downloadable?
      options[:response_content_disposition] = %{attachment; filename="#{attachment.original_filename}"}
    end

    if attachment.options[:storage].to_sym == :s3
      attachment.expiring_url(expires)
    else
      attachment.url
    end
  end

  def s3_url_options
    if downloadable?
      { response_content_disposition: %{attachment; filename="#{attachment.original_filename}"} }
    else
      { }
    end
  end

  def date
    [attachment_updated_at, created_at, Time.now].compact.first.utc.to_date
  end

  def search
    super.merge(string: "#{self.name} #{self.path}")
  end

  private

  def generate_random_secret
    self.random_secret ||= SecureRandom.hex(8)
  end
end

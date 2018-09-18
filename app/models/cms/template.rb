class CMS::Template < ApplicationRecord

  include CMS::Filtering

  scope :with_draft, ->{ where(['draft IS NOT NULL'])}
  scope :for_rails_view, lambda { |path| where(rails_view_path: path.to_s) }

  scope :but, lambda { | *klasses | where{ type.not_in klasses.map(&:to_s) } }
  scope :recents, -> { order(updated_at: :desc).where.has { updated_at != created_at } }
  attr_accessible :provider, :draft, :liquid_enabled, :handler

  self.table_name = :cms_templates

  belongs_to :provider, class_name: 'Account'
  has_many :versions, as: :template

  validates :provider, presence: true
  validates :system_name, uniqueness: { :scope => [:provider_id, :type], :allow_blank => true },
            format: { :with => /\A\w[\w\-\/_]+\z/, :allow_blank => true }, length: { maximum: 255 }
  validates :handler, inclusion: { in: CMS::Handler.available, allow_blank: false, allow_nil: true },
            length: { maximum: 255 }
  validates :options, length: { maximum: 65535 }
  validates :draft, :published, length: { maximum: 16777215 }
  validates :type, :path, :title, :content_type, :updated_by, :rails_view_path,
            length: { maximum: 255 }

  validate :check_liquid_syntax

  before_save :set_updated_by
  before_save :set_rails_view_path
  after_validation :create_first_version, on: :update


  # remove this when all code will read from #published and not #body
  alias_attribute :body, :published

  symbolize :handler

  def publish!
    if draft
      publish
      save!
    end
  end

  def hide!
    if self[:published]
      self.published = nil
      save!
    end
  end

  def revert!
    self.draft = nil
    save!
  end

  def name
    title.presence or system_name
  end

  # Interface change suggestion:
  #
  # 1) remove 'content' and 'current' - client always knows what he
  #    wants
  #
  # 2) replace with
  #
  # def draft
  #   read_attribute(:draft) || read_attribute(:published)
  # end
  #
  # def published
  #   read_attribute(:published)
  # end
  #

  def content(include_draft = nil)
    include_draft ? current : published
  end

  def current
    draft or published
  end

  def build_version(attrs = {})
    version = versions.build
    version.assign_attributes(version_attributes.merge(attrs), :without_protection => true)
    version
  end

  def version_attributes
    attributes_for_version(dup.attributes)
  end

  def revert_to(version)
    assign_attributes version.revert_attributes
    self
  end

  def version
    updated_at.utc.to_i
  end

  def save(*)
    raise "#{self.inspect} cannot be saved because it is CMS::Template" if self.class == CMS::Template
    super
  end

  def dirty?
    self.draft != nil
  end

  def mime_type
    Mime::Type.lookup(content_type) if content_type.present?
  end

  # Backups a current template version as '[3scale System]' and
  # publishes a new version of the content.
  #
  # When upgrading Liquid tags/drops to a new version or removing
  # some compatibility issues, this method is called by Rake
  # so that you
  #
  def upgrade_content!(new_version, validate: true)
    build_version(updated_by: '[3scale System]')
    self.published = new_version
    save!(validate: validate)
  end

  def human_type
    string = type.gsub('CMS::', '')
                  .gsub('::', ' ')
                  .gsub('Builtin', 'Built-in')
                  .gsub('EmailTemplate', 'Email Template')
  end

  protected

  def set_rails_view_path; end # to be overriden in subclasses

  def set_updated_by
    self.updated_by = User.current.try!(:username) || ''
  end

  private

  def create_first_version
    if versions.count == 0
      attributes = attributes_for_version(CMS::Template.find(id).dup.attributes)
      build_version(attributes)
    end
  end

  def attributes_for_version(attributes)
    attributes.keep_if{ |k,v| CMS::Template::Version.versioned_column?(k) }
              .symbolize_keys
              .merge(
                type: "CMS::Template::Version",
                created_at: Time.zone.now
              )
  end

  def self.full_path(path)
    DeveloperPortal::VIEW_PATH.join(path)
  end

  def check_liquid_syntax
    if liquid_enabled? && draft
      begin
        Liquid::Template.parse(draft)
      rescue Liquid::SyntaxError => e
        errors.add(:draft, e.message)
      rescue
        # TODO: remove the general rescue?
        errors.add(:draft, :liquid_syntax)
      end
    end
  end

  def publish
    self.published = draft
    self.draft = nil
    build_version
  end
end

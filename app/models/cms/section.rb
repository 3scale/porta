class CMS::Section < ApplicationRecord
  include CMS::Filtering
  extend System::Database::Scopes::IdOrSystemName
  include NormalizePathAttribute
  attr_accessible :provider, :parent, :title, :system_name, :public, :group, :partial_path

  self.table_name = :cms_sections

  belongs_to :provider, :class_name => 'Account'

  has_many :builtins, :class_name => 'CMS::Builtin'

  has_many :pages, :class_name => 'CMS::Page'
  has_many :files, :class_name => 'CMS::File'

  has_many :children, :class_name => 'CMS::Section', :foreign_key => :parent_id
  belongs_to :parent, :foreign_key => :parent_id, :class_name => 'CMS::Section'

  alias sections children
  alias section= parent=

  validates :system_name, :provider, presence: true
  validates :parent_id, presence: { :unless => :root? }

  validates :title, uniqueness: { :scope => [:provider_id, :parent_id] }
  validates :system_name, uniqueness: { :scope => [:provider_id] }, length: { maximum: 255 }
  validates :partial_path, :title, :type, length: { maximum: 255 }

  before_validation :set_system_name , :on => :create
  before_validation :set_partial_path, :on => :create
  verify_path_format :partial_path
  before_validation :set_provider, :on => :create

  before_destroy :not_root?

  validate :not_own_child

  has_many :group_sections, :class_name => 'CMS::GroupSection'
  has_many :groups, :class_name => 'CMS::Group', :through => :group_sections

  before_save :strip_trailing_slashes

  def to_xml(options = {})
    xml = options[:builder] || Nokogiri::XML::Builder.new

    xml.section do |x|
      unless new_record?
        xml.id id
        xml.created_at created_at.xmlschema
        xml.updated_at updated_at.xmlschema
      end
      x.partial_path partial_path
      x.public public
      x.title title
      x.parent_id parent_id
      x.system_name system_name
    end

    xml.to_xml
  end

  module ProviderAssociationExtension
    def root
      self.find_by_system_name('root')
    end

    def root!
      self.find_by_system_name!('root')
    end

    def partial_paths
      self.select('id, partial_path, tenant_id').map{ |section| [section.id, section.partial_path] }
    end

    def find_or_create!(name, path, options = {})
      system_name = name.downcase

      if section = find_by_system_name(system_name)
        section
      else
        with_defaults = options.reverse_merge!(partial_path: path, system_name: system_name, title: name, public: true, parent: root)
        create!(with_defaults)
      end
    end
  end

  def full_path
    path_from_root = parent ? parent.full_path : "/"
    path_from_root.gsub!(/([^\/])$/,"\\1/")
    self.root? ? path_from_root : (path_from_root + partial_path).gsub(/\/+/,"/")
  end

  def search
    super.merge string: "#{self.title} #{self.system_name}"
  end

  def protected?
    not public?
  end

  # def partial_path=(value)
  #   @partial_path = value.gsub(/\A\/+/,'').gsub(/\/+$/,'')
  # end

  alias restricted_access? protected?

  def accessible_by?(buyer)
    return true if root? && public?
    if public?  # buyer can be nil (non logged users)
      parent.accessible_by?(buyer)
    else # protected. buyer has to be an Account
      buyer && buyer.accessible_sections.include?(self) && parent.accessible_by?(buyer)
    end
  end

  def root?
    system_name.to_s == "root"
  end

  # Adds or removes `model_type` elements from/to the section,
  # that it only includes those from `inside_ids`.
  #
  # TODO : doc this
  #
  def add_remove_by_ids( model_type, inside_ids)
    all = provider.send(model_type.to_s.pluralize)
    inside = self.send(model_type.to_s.pluralize)

    inside_ids = (inside_ids || []).uniq

    to_keep, to_delete = inside.partition { |p| inside_ids.include?(p.id.to_s) }
    to_add = inside_ids - to_keep.map{ |k| k.id.to_s}

    to_add.each do |file_id|
      if all.exists?(file_id) &&  all.find(file_id).valid?
        inside << all.find(file_id)
      end
    end

    to_delete.each{|a| a.section = provider.sections.root; a.save} unless self.root?
  end


  # TODO: optimize
  def dirty?
    self.children.any? { |c| c.dirty? } ||
      self.files.any? { |f| f.dirty? } ||
      self.pages.any? { |p| p.dirty? } ||
      self.builtins.any? { |p| p.dirty? }
  end

  def destroy
    unless root?
      CMS::Section.transaction do
        builtins.each{|p| p.section = parent; p.save!}
        pages.each   {|p| p.section = parent; p.save!}
        files.each   {|f| f.section = parent; f.save!}
        children.each{|s| s.parent = parent; s.save!}
        super
      end
    end
  end

  def child_of?(ancestor_id)
    if parent.present?
      return (parent_id == ancestor_id) || parent.child_of?(ancestor_id)
    else
      return false
    end
  end

  protected

  def set_system_name
    self.system_name = self.title if self.title && self.system_name.blank?
  end

  def set_partial_path
    if partial_path.blank?
      self.partial_path = root? ? '/' : title.try!(:parameterize)
    end
  end

  def set_provider
    self.provider = parent.provider if self.parent && self.provider.nil?
  end

  def not_root?
    throw :abort if root?
  end


  def label
    title || system_name
  end

  private

  def not_own_child
    if child_of?(self.id)
      errors.add(:base, "cannot be it's own ancestor")
    end
  end

  def strip_trailing_slashes
    self.partial_path.to_s.gsub!(/^\/+/,"/")
  end
end

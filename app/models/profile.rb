class Profile < ApplicationRecord
  #TODO: this whole model needs clean up, there's lots of old and unneeded logic here

  serialize :customers_type
  validates :company_size, presence: true
  validates :company_type, presence: { :if => :company_profile? }

  # this validation should be out of the 'validates_presence_of' because
  # signup_without_plan_with_account_profile makes use of the
  # 'account#accepts_nested_attributes_for :profile' and that creates a circular dependency
  # with the account validation that causes profile#valid? to be false
  before_save :validate_presence_of_account

  attr_protected :account_id, :tenant_id, :audit_ids

  after_initialize :set_company_size

  audited :allow_mass_assignment => true
  state_machine :initial => :private do

    state :private
    state :pending
    state :published

    event :submit do
      transition :private => :pending
    end

    event :publish do
      transition :pending => :published
      transition :private => :published
    end

    event :hide do
      transition :pending => :private
      transition :published => :private
    end
  end

  belongs_to :account
  delegate :s3_provider_prefix, to: :account

  # Profile has attached logo.
  has_attached_file :logo,
    :styles => { large: '300x300>'.freeze, medium: '150x150>'.freeze, thumb: '100x100>'.freeze, invoice: ['200x50>'.freeze, :png].freeze }.freeze,
    :url => ':url_root/:account_id/:class/:attachment/:style/:basename.:extension'.freeze,
    :s3_permissions => 'public-read'.freeze,
    :default_url => '/assets/3scale-logo.png'.freeze
  do_not_validate_attachment_file_type :logo


  # Find only published profiles.
  scope :published, -> { where(:state => 'published') }

  # Find only pending profiles.
  scope :pending, -> { where(:state => 'pending') }

  CustomCompanyType = "Other"
  CompanyTypes = [ "Independent Software Vendor (ISV)",
                   "Original Device Manufacturer (ODM)",
                   "Original Equipment Manufacturer (OEM)",
                   "Web Domain",
                   "Integrator or Value-Added Reseller",
                   CustomCompanyType ]
  CustomerTypes = ["Consumers", "Businesses", "Both"]
  #this can be more numerically expressed using ranges, serializing them, and adding logic
  # on their upper and lower bounds. But for now the strings will do
  # (0..1) => range for individual
  IndividualNotCompany = "I'm an individual, not an organization"
  CompanySizes = [ IndividualNotCompany,
                   "1 to 50",       # (1..50)
                   "51 to 300",
                   "301 to 1000",
                   "More than 1000" ] # (1001..pick_a_number)

  # and this of course could check upper bound of range > 1
  def individual_profile?
    company_size.present? and company_size == IndividualNotCompany
  end

  def company_profile?
    !company_size.blank? and !individual_profile?
  end

  def name
    account && account.org_name
  end

  def editable_by?(user)
    user.id == account_id
  end

  def company_url= val
    self[:company_url] = fix_http(val)
  end

  def blog_url= val
    self[:blog_url] = fix_http(val)
  end

  def rssfeed_url= val
    self[:rssfeed_url] = fix_http(val)
  end

  protected

  def validate_presence_of_account
    !self.account.nil?
  end

  def fix_http str
    return '' if str.blank?
    str.starts_with?('http') ? str.sub(/http:\/\//, '') : str
  end

  delegate :provider_id_for_audits, :to => :account, :allow_nil => true

  private

  #issue 7486981, this is needed since Account accepts_nested_attrs from profile
  # and account edit checks if profile is valid, which is false on initialization
  def set_company_size
    self.company_size ||= IndividualNotCompany
  end
end

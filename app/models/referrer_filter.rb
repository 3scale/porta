class ReferrerFilter < ApplicationRecord
  REFERRER_FILTERS_LIMIT = 5

  belongs_to :application, :class_name => 'Cinstance', :inverse_of => :referrer_filters

  validates :application, presence: true
  validates :value, presence: true
  validates :value, uniqueness: { scope: [:application_id] }
  validates :value, format: { with: /\A[a-zA-Z0-9*.-]+\z/ }, length: { maximum: 255 }

  validate :keys_limit_reached

  attr_accessible :application, :value

  attr_readonly :value

  before_destroy :cache_needed_associations

  delegate :account, to: :application

  extend BackendClient::ToggleBackend

  module AssociationExtension
    include System::AssociationExtension

    def add(value)
      record = build(:value => value, :application => proxy_association.owner)

      # if record is not saved, remove it from collection
      delete(record) if not record.save

      record
    end

    def pluck_values
      # if the association is loaded, just take it from memory,
      # otherwise take one column from database
      proxy_association.loaded? ? map(&:value) : pluck(:value)
    end

    def get(value)
      proxy_association.target.find{|record| record.value == value }
    end

    def remove(value)
      record = get(value) || find_by_value!(value)
      delete(record)
      record
    end

    # just > because in that point of time record is in the association
    def limit_reached?
      size > REFERRER_FILTERS_LIMIT
    end

    def can_add?
      self.reject(&:new_record?).size < REFERRER_FILTERS_LIMIT
    end
  end

  def to_xml(options = {})
    builder = options[:builder] || ThreeScale::XML::Builder.new

    builder.referrer_filter do |xml|
      xml.value value

      if persisted?
        xml.id_ id
        xml.updated_at updated_at
        xml.created_at created_at
      end
    end

    builder.to_xml
  end

  def update_backend_value
    ThreeScale::Core::ApplicationReferrerFilter.save(application.service.backend_id,
                                                     application.application_id,
                                                     value)
  end

  def destroy_backend_value
    ThreeScale::Core::ApplicationReferrerFilter.delete(application.service.backend_id,
                                                       application.application_id,
                                                       value)

  end

  protected

  def cache_needed_associations
    self.application
  end

  def keys_limit_reached
    filters = application.try!(:referrer_filters)

    if filters && filters.limit_reached?
      errors.add(:base, :limit_reached)
    end
  end

end

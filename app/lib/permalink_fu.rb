# frozen_string_literal: true

module PermalinkFu
  extend ActiveSupport::Concern

  included do
    def permalink_origin_attribute_must_contain_latin_characters
      errors.add(self.class.permalink_attribute, 'must contain latin characters') if permalink.blank?
    end
  end

  module ClassMethods
    attr_reader :permalink_options
    attr_reader :permalink_attribute

    def permalink(attr_name, options = {})
      @permalink_attribute  = attr_name
      @permalink_options    = options
      before_validation :create_unique_permalink
      validate :permalink_origin_attribute_must_contain_latin_characters
      validates :permalink, length: { maximum: 255 }
    end
  end

  private

  def create_unique_permalink
    return if permalink.present? && !permalink_changed?
    base_permalink = build_permalink_from_attribute
    count = where_match_permalink_with_conditions(base_permalink).count
    self.permalink = count.positive? ? "#{base_permalink}-#{count + 1}" : base_permalink
  end

  def where_match_permalink_with_conditions(permalink)
    record_class = self.class
    conditions = record_class.where.has { sift(:regexp, :permalink, "^#{permalink}(-[0-9]+)?$") }
    conditions = conditions.where.not(id: id) if id
    scope = record_class.permalink_options[:scope]
    conditions = conditions.where(scope => send(scope)) if scope
    conditions
  end

  def build_permalink_from_attribute
    send(self.class.permalink_attribute).to_s.parameterize
  end
end

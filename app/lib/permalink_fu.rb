# frozen_string_literal: true

module PermalinkFu
  extend ActiveSupport::Concern

  included do
    def permalink_must_contain_latin_characters
      return if permalink.present?
      errors.add(self.class.permalink_attribute, 'must contain latin characters')
    end
  end

  module ClassMethods
    attr_reader :permalink_options
    attr_reader :permalink_attribute

    def permalink(attr_name, options = {})
      @permalink_attribute  = attr_name
      @permalink_options    = options
      before_validation :create_unique_permalink
      validate :permalink_must_contain_latin_characters
    end
  end

  private

  def create_unique_permalink
    base_permalink = permalink.presence || build_permalink_from_attribute
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

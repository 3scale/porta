require 'digest/sha1'

module PermalinkFu
  class << self
    attr_accessor :translation_to
    attr_accessor :translation_from

    def escape(str)
      str.parameterize
    end
  end

  def self.included(base)
    base.extend ClassMethods
    class << base
      attr_accessor :permalink_options
      attr_accessor :permalink_attributes
      attr_accessor :permalink_field
    end
  end

  module ClassMethods
    # Specifies the given field(s) as a permalink, meaning it is passed through PermalinkFu.escape and set to the permalink_field.  This
    # is done
    #
    #   class Foo < ActiveRecord::Base
    #     # stores permalink form of #title to the #permalink attribute
    #     has_permalink :title
    #
    #     # stores a permalink form of "#{category}-#{title}" to the #permalink attribute
    #
    #     has_permalink [:category, :title]
    #
    #     # stores permalink form of #title to the #category_permalink attribute
    #     has_permalink [:category, :title], :category_permalink
    #
    #     # add a scope
    #     has_permalink :title, :scope => :blog_id
    #
    #     # add a scope and specify the permalink field name
    #     has_permalink :title, :slug, :scope => :blog_id
    #   end
    #
    def has_permalink(attr_names = [], permalink_field = nil, options = {})
      if permalink_field.is_a?(Hash)
        options = permalink_field
        permalink_field = nil
      end
      self.permalink_attributes = Array(attr_names)
      self.permalink_field      = permalink_field || :permalink
      self.permalink_options    = options
      before_validation :create_unique_permalink
      validates_with ::PermalinkFu::PermalinkValidator
    end
  end

  class PermalinkValidator < ActiveModel::Validator
    def validate(record)
      return if record.public_send(record.class.permalink_field).present?
      attributes_to_sentence = record.class.permalink_attributes.to_sentence(two_words_connector: ' or ', last_word_connector: ', or ')
      record.errors.add(:base, "#{attributes_to_sentence} must contain latin characters")
    end
  end

  protected

  def create_unique_permalink
    if send(self.class.permalink_field).to_s.empty?
      send("#{self.class.permalink_field}=", create_permalink_for(self.class.permalink_attributes))
    end
    base       = send(self.class.permalink_field)
    counter    = 1
    # oh how i wish i could use a hash for conditions
    conditions = ["#{self.class.permalink_field} = ?", send(self.class.permalink_field)]
    unless new_record?
      conditions.first << " and id != ?"
      conditions       << id
    end
    if self.class.permalink_options[:scope]
      conditions.first << " and #{self.class.permalink_options[:scope]} = ?"
      conditions       << send(self.class.permalink_options[:scope])
    end

    # FIXME: holly cow, this is iterating through every similar record in database
    # and tries to find empty spot
    # not only it is performance hog, but can result in DOS
    while self.class.where(conditions).count > 0
      conditions[1] = "#{base}-#{counter += 1}"
      send("#{self.class.permalink_field}=", conditions[1])
    end
  end

  def create_permalink_for(attr_names)
    attr_names.collect do |attr_name|
      ::PermalinkFu.escape(send(attr_name).to_s)
    end.reject(&:blank?).join('-')
  end
end

PermalinkFu.translation_to   = 'ascii//ignore//translit'
PermalinkFu.translation_from = 'utf-8'

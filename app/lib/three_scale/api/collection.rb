# frozen_string_literal: true

class ThreeScale::Api::Collection
  def initialize(collection, options = {})
    @collection = collection
    @options = options
  end

  def to_xml(options = {})
    builder = options[:builder] || ThreeScale::XML::Builder.new

    root = options.delete(:root) || @options.delete(:root)
    # merge options passed when creating collection with the ones passed now together with builder
    options = options.merge(@options).merge(builder: builder, skip_instruct: true)

    builder.tag!(root, pagination_attrs) do |xml|
      each do |item|
        item.to_xml(options)
      end
    end

    builder.to_xml
  end

  def to_json(options = {})
    MultiJson.dump collection.to_hash(options).merge(pagination_attrs(wrapper: :metadata))
  end

  def method_missing(method_name, *arguments, &block)
    represented.send(method_name, *arguments, &block)
  end

  # http://robots.thoughtbot.com/post/28335346416/always-define-respond-to-missing-when-overriding

  def respond_to_missing?(method_name, include_private = false)
    @collection.respond_to?(method_name, include_private)
  end

  private

  attr_reader :collection

  def represented
    @represented ||= collection.try(:represented) || collection
  end

  def pagination_attrs(wrapper: nil)
    return {} if represented.per_page >= represented.total_entries

    pagination = %i[per_page total_entries total_pages current_page].each_with_object({}) do |meta_field, pagination_hash|
      pagination_hash[meta_field] = represented.public_send(meta_field)
    end
    pagination = {wrapper => pagination} if wrapper
    pagination
  rescue NoMethodError
    {}
  end
end

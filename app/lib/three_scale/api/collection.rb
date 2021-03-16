# frozen_string_literal: true

class ThreeScale::Api::Collection
  def initialize(collection, options = {})
    @collection = collection
    @options = options
  end

  def to_xml(xml_options = {})
    builder = xml_options[:builder] || ThreeScale::XML::Builder.new
    opts = options.merge(xml_options).merge(builder: builder, skip_instruct: true)

    builder.tag!(opts.delete(:root), pagination_metadata) do |xml|
      represented.each { |item| item.to_xml(opts) }
    end

    builder.to_xml
  end

  def to_json(json_options = {})
    MultiJson.dump collection.to_hash(json_options).merge(pagination_metadata(wrapper: :metadata))
  end

  # rubocop:disable Lint/MissingSuper
  def method_missing(method_name, *arguments, &block)
    represented.send(method_name, *arguments, &block)
  end
  # rubocop:enable Lint/MissingSuper

  # http://robots.thoughtbot.com/post/28335346416/always-define-respond-to-missing-when-overriding
  # :reek:BooleanParameter ThreeScale::Api::Collection#respond_to_missing? has boolean parameter 'include_private'
  # :reek:ManualDispatch ThreeScale::Api::Collection#respond_to_missing? manually dispatches method call
  # rubocop:disable Lint/MissingSuper
  def respond_to_missing?(method_name, include_private = false)
    collection.respond_to?(method_name, include_private)
  end
  # rubocop:enable Lint/MissingSuper

  private

  PAGINATION_METADATA = %i[per_page total_entries total_pages current_page].freeze
  private_constant :PAGINATION_METADATA

  attr_reader :collection, :options

  def represented
    collection.try(:represented) || collection
  end

  def pagination_metadata(wrapper: nil)
    return {} unless paginated?

    wrapper ? {wrapper => pagination_attrs} : pagination_attrs
  end

  def pagination_attrs
    PAGINATION_METADATA.each_with_object({}) do |meta_field, pagination_hash|
      pagination_hash[meta_field] = represented.public_send(meta_field)
    end
  end

  def paginated?
    represented.per_page < represented.total_entries
  rescue NoMethodError
    false
  end
end

class ThreeScale::Api::Collection

  include PaginationHelper::ClassMethods

  def initialize(collection, options = {})
    @collection = collection
    @options = options
  end

  def to_xml(options = {})
    builder = options[:builder] || ThreeScale::XML::Builder.new

    root = options.delete(:root) || @options.delete(:root)
    # merge options passed when creating collection with the ones passed now together with builder
    options = options.merge(@options).merge(builder: builder, skip_instruct: true)

    builder.tag!(root, pagination) do |xml|
      each do |item|
        item.to_xml(options)
      end
    end

    builder.to_xml
  end

  def method_missing(method_name, *arguments, &block)
    collection = @collection.try(:represented) || @collection
    collection.send(method_name, *arguments, &block)
  end

  # http://robots.thoughtbot.com/post/28335346416/always-define-respond-to-missing-when-overriding

  def respond_to_missing?(method_name, include_private = false)
    @collection.respond_to?(method_name, include_private)
  end

  private

  def pagination
    pagination_attrs(@collection)
  end
end

class Array
  alias count size unless instance_methods.include?(:count)

  # Partial backport from Rails 3.2
  def to_xml(options = {})
    options = options.dup
    options[:root]     ||= all? { |e| e.is_a?(first.class) && first.class.to_s != "Hash" } ? first.class.to_s.underscore.pluralize.tr('/', '-') : "records"
    options[:builder]  ||= ThreeScale::XML::Builder.new
    options[:skip_types] = true unless options.has_key?(:skip_types)


    root = options.delete(:root).to_s
    root = root.dasherize if options.delete(:dasherize)
    # children = options.delete(:children)
    children = options.delete(:children) || root.singularize

    builder = options[:builder]

    attributes = options.delete(:skip_types) ? {} : {:type => "array"}

    opts = options.merge({ :root => children })

    if empty?
      builder.__send__(:method_missing, root, attributes)
    else
      builder.__send__(:method_missing, root, attributes) do |builder|
        each { |value| ActiveSupport::XmlMini.to_tag(children, value, options) }
        yield builder if block_given?
      end
    end

    builder.to_xml
  end
end

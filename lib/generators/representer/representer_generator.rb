class RepresenterGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)

  argument :name, type: :string

  def generate_representer
    template "resource_representer.rb.erb", "app/representers/#{singular.underscore}_representer.rb"
    template "collection_representer.rb.erb", "app/representers/#{plural.underscore}_representer.rb"
  end

  protected

  def class_name
    name.singularize.camelize
  end

  def singular
    class_name.singularize
  end

  def plural
    class_name.pluralize
  end
end

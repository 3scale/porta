module Liquid
  module Forms

    class Error < StandardError; end
    class NotFoundError < Error; end
    class MissingObjectError < Error; end

    # Looks up a form class by it's name, for example.
    #
    # 'application.create' => Liquid::Forms::Application::Create
    # 'application.update' => Liquid::Forms::Application::Update
    # 'signup' => Liquid::Forms::Signup
    #
    # see lib/liquid/forms/* for all possible names.
    #
    def self.find_class_by_name(form_name)
      name_parts = form_name.split('.')

      klass = case name_parts.length
              when 1
                # simple name such as 'signup'
                const_get(form_name.camelize, false)
              when 2
                # namespaced form such as 'application.update'
                object, method = name_parts
                namespace = const_get(object.camelize, false)
                namespace.const_get(method.camelize, false)
              end

      if klass.is_a?(Class)
        klass
      else
        raise NotFoundError, "Unknown form '#{form_name}'"
      end
    rescue NameError => ex
      raise unless ex.message =~ /uninitialized constant/
      raise NotFoundError, "Unknown form '#{form_name}'"
    end
  end
end

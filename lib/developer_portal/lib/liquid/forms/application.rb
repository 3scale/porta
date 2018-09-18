module Liquid
  module Forms
    module Application
      class Create < Forms::Create
        def html_class_name
          'cinstance'
        end

        def object_param_name(model)
          'application'
        end

        def path
          admin_applications_path(service_id: service.id)
        end

        def service
          object.plan.service
        end
      end

      class Update < Forms::Update
        def html_class_name
          'cinstance'
        end

        def object_param_name(model)
          'application'
        end

        def path
          admin_application_path(id)
        end
      end

      class Updateremote < Update
        def html_class_name
          "cinstance remote"
        end
      end

    end
  end
end

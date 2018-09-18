module Liquid
  module Forms
    module ReferrerFilter

      class Createremote < Forms::Create
        def html_class_name
          "referrer_filter remote"
        end

        def path
          admin_application_referrer_filters_path(application_id: object.application.id)
        end
      end

    end
  end
end


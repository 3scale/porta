module Liquid
  module Forms
    module User

      class Edit < Forms::Update

        def html_class_name
          'edit-user-form'
        end

        def path
          admin_account_user_path(object.id)
        end

        def form_options
          super.merge(id: "edit_user_#{object.id}")
        end

      end

      class PersonalDetails < Forms::Update

        def html_class_name
          'personal_details'
        end

        def form_options
          super.merge(id: 'edit_personal_details')
        end

        def path
          admin_account_personal_details_path
        end

        def origin_tag
          tag(:input, type: :hidden, name: 'origin', value: controller.params.present? ? controller.params[:origin] : '')
        end

        def render(content)
          super(origin_tag + content)
        end

      end
    end
  end
end

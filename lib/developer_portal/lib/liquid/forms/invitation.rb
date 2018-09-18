module Liquid
  module Forms
    module Invitation
      class Create < Forms::Create
        def html_class_name
          "invitation-form"
        end

        def path
          admin_account_invitations_path
        end
      end
    end
  end
end

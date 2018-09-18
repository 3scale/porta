module Liquid
  module Forms
    module Account

      class BillingAddress < Forms::Update
        def html_class_name
          'formtastic account'
        end

        def path
          admin_account_payment_details_path
        end
      end

      class PersonalDetails < Forms::Update
        def html_class_name
          'formtastic account'
        end

        def path
          admin_account_path
        end
      end

    end
  end
end

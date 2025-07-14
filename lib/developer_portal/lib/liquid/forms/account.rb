module Liquid
  module Forms
    module Account

      class BillingAddress < Forms::Update
        def html_class_name
          'formtastic account'
        end

        def path
          polymorphic_path([:admin, :account, payment_gateway_type])
        end

        private

        def payment_gateway_type
          @payment_gateway_type ||= context.registers[:site_account].payment_gateway_type
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

module Liquid
  module Forms
    # Subscription == ServiceContract
    #
    # semantic_form_for @service_contract, url: admin_service_contracts_path
    module Subscription
      class Create < Forms::Create
        def html_class_name
          'formtastic service_contract'
        end

        def path
          admin_service_contracts_path
        end
      end
    end
  end
end

module Liquid
  module Forms
    # Subscription == ServiceContract
    #
    # semantic_form_for @service_contract, url: admin_service_contracts_path
    module Contract
      class Create < Forms::Update
        def html_class_name
          'formtastic service_contract'
        end

        def path
          admin_contract_path(@object)
        end
      end
    end
  end
end

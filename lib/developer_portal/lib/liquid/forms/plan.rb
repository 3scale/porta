module Liquid
  module Forms
    module Plan
      class Change < Forms::Update

        def path
          buyer_account_contract_path
        end

      end
    end
  end
end

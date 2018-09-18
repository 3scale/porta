class CreateMissingServiceAndAccountContracts < ActiveRecord::Migration
  def self.up

    Service.reset_column_information
    ServiceContract.reset_column_information

    missing_service_contracts = %{
      -- returns account_id AND service_id for accounts not without service contract of that service
      -- skips services without applications
      SELECT accounts.id AS account_id, services.id AS service_id FROM accounts
      LEFT JOIN cinstances ON accounts.id = cinstances.user_account_id AND cinstances.type = 'Cinstance'
      LEFT JOIN plans ON cinstances.plan_id = plans.id
      LEFT JOIN services ON plans.issuer_id = services.id
      LEFT JOIN (
        SELECT cinstances.*, issuer_id AS service_id FROM cinstances
        LEFT JOIN plans ON cinstances.plan_id = plans.id
        WHERE cinstances.type = 'ServiceContract') service_contracts ON accounts.id = service_contracts.user_account_id  AND service_contracts.service_id = services.id
      LEFT JOIN plans service_plans ON service_contracts.plan_id = service_plans.id
      WHERE accounts.buyer = true AND accounts.deleted_at IS NULL AND service_plans.issuer_id IS NULL AND cinstances.id IS NOT NULL;
    }

    aporove_all_service_contracts = %{
      UPDATE cinstances SET state = 'live' WHERE type = 'ServiceContract';
    }

    Account.transaction do

      select_all(missing_service_contracts).each do |missing_contract|
        account = Account.find(missing_contract['account_id'])
        service = Service.find_by_id(missing_contract['service_id']) || account.services.first # FIXME: weird connect migration issue

        next unless service
        plan = service.service_plans.default_or_first || service.service_plans.first

        next unless plan
        contract = account.buy(plan)
      end

      execute aporove_all_service_contracts
    end
  end

  def self.down
  end
end

class ServiceContractMessenger < ContractMessenger

  def setup(contract)
    super
    @service = contract.service
    assign_drops :service => @service,
                 :service_contract => Liquid::Drops::Contract.new(contract),
                 :subscription => Liquid::Drops::Contract.new(contract)
  end

  def new_contract(contract)
    super contract, :subject => 'API System: New Service subscription'
  end

  def accept(contract)
    super contract, :subject => 'API System: Service subscription has been accepted'
  end

  def reject(contract)
    super contract, :subject => 'API System: Service subscriptions has been rejected'
  end
end

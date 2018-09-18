module DefaultPlanProxy
  include System::AssociationExtension

  def default
    proxy_association.owner.send(belongs_to_name)
  end

  alias default_or_nil default

  def default=(plan)
    proxy_association.owner.send("#{belongs_to_name}=", plan)
  end

  def default!(plan)
    self.default = plan
    proxy_association.owner.save!
    plan
  end

  def default_or_first
    default or published.first
  end

  private

  # for AccountPlan returns `default_account_plan`
  #
  def belongs_to_name
    "default_#{proxy_association.reflection.class_name.underscore}"
  end

  def has_many_name
    "#{proxy_association.reflection.class_name.underscore}s"
  end


end

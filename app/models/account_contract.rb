class AccountContract < Contract
  alias account_plan plan
  attr_reader :old_plan

  belongs_to :user_account, class_name: 'Account', inverse_of: :bought_account_contract, autosave: false

  # TODO: remove this when also Account states (pending, aproved ...) are handled on an
  # account contract.
  #
  def has_lifecycle?
    false
  end

  def to_xml(options = {})
    xml = options[:builder] || ThreeScale::XML::Builder.new

    xml.contract do |xml|
      xml.id_ id unless new_record?

      plan.to_xml(:builder => xml)
    end

    xml.to_xml
  end

  # TODO: does it makes sense to expose this method in account? to do:
  # account.change_plan! directly avoiding Demeter's Law breaks in controllers
  #
  # this comment means inherited Contract#change_plan and Contract#change_plan!
  #

  private

  #
  # Overrides Contract protected method to run WebHooks after sucessful plan change
  #

  def change_plan_internal(new_plan)
    if result = super
      user_account.push_web_hooks_later(:event => "plan_changed")
      result
    end
  end

  def correct_plan_subclass?
    unless self.plan.is_a? AccountPlan
      errors.add(:plan, 'plan must be an AccountPlan')
    end
  end

end

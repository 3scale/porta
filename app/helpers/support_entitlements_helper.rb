# frozen_string_literal: true

module SupportEntitlementsHelper
  def sku(plan)
    if plan.trial?
      'SER0541 (90 Day Supported Eval)'
    elsif plan.paid?
      'MCT3712 (Basic Plus Support)'
    end
  end
end

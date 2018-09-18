# frozen_string_literal: true

require_dependency 'three_scale'

module ThreeScale::OnPremises
  extend ActiveSupport::Concern

  protected

  def deny_on_premises_for_master
    raise CanCan::AccessDenied if ThreeScale.master_on_premises?
  end

  def deny_on_premises
    raise CanCan::AccessDenied if ThreeScale.config.onpremises
  end
end

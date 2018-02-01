class MemberPermission < ApplicationRecord
  include Symbolize
  belongs_to :user, touch: true
  validates :admin_section, inclusion: { :in => ->(_record) { AdminSection.sections } }
  validates :admin_section , uniqueness: { :scope => :user_id, if: Proc.new { |mp| mp.user_id } }
  serialize :service_ids, JSON

  symbolize :admin_section
  # def admin_section
  #   AdminSection.all[admin_section]
  # end

  def service_ids=(ids)
    super Array(ids).reject(&:blank?).map(&:to_i)
  end

  def section_name
    admin_section.to_s
  end

  def has_service?(service)
    Array(service_ids).include?(service.try(:id) || service)
  end
end

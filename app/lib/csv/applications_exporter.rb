# frozen_string_literal: true

class Csv::ApplicationsExporter < ::Csv::Exporter

  def generate
    super do |csv|
      csv << header
      csv << []
      csv << basic_fields

      query = @account.provided_cinstances
                .includes([ { :user_account => [:users, :country] }, :plan])
                .order('`cinstances`.`created_at` DESC')

      query = query.where(created_at: @range) if @range
      query.find_each do |cinstance|
        buyer = cinstance.user_account
        next unless buyer
        admin = buyer.admins.first
        next unless admin

        csv << values_for(admin, cinstance, buyer)
      end
    end
  end

  def values_for(admin, cinstance, buyer)
    [
      cinstance.id,
      cinstance.name,
      cinstance.plan.name,
      cinstance.account.name,
      cinstance.issuer.name,
      cinstance.state,
      cinstance.created_at,
      cinstance.first_daily_traffic_at,
      (cinstance.plan.free? ? 'free' : 'paid'),
      (cinstance.description.strip if cinstance.description),
      admin.username,
      (admin.first_name.strip if admin.first_name),
      (admin.last_name.strip if admin.last_name),
      (cinstance.extra_fields.to_json if cinstance.extra_fields),
      buyer.org_name.strip,
      (buyer.org_legaladdress.strip if buyer.org_legaladdress),
      buyer.country.try!(:name),
      buyer.country.try!(:code),
      admin.email,
      (buyer.telephone_number.strip if buyer.telephone_number),
      admin.created_at
    ]
  end

  def basic_fields
    ["Application ID", "Application Name", "Plan", "Account Name", "Service Name",
     "Application State", "Application Created At", "Traffic On", "Paid?", "Intentions",
     "Username", "First Name", "Last Name", "User Specific Data", "Organization Name",
     "Legal Address", "Country", "Country Code", "Email", "Telephone Number", "Registered"]
  end
end

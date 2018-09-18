# frozen_string_literal: true

class Csv::BuyersExporter < ::Csv::Exporter

  def generate
    super do |csv|
      csv << header
      csv << [] # empty line between header and output
      csv << account_headers
      query = @account.buyer_accounts.includes(:admin_users, :country, :bought_account_plan)
      query = query.where(created_at: @range) if @range
      query.find_each do |account|
        csv << values_for_account(account)
      end
    end
  end

  def values_for_account(account)
    [
      account.id,
      account.state,
      account.org_name,
      account.country.try!(:name),
      account.bought_account_plan.try!(:name),
      account.created_at.to_s(:db),
      account.bought_cinstances.count,
      account.first_admin.try!(:display_name),
      account.first_admin.try!(:email),
      account.extra_fields.to_json,
      account.first_admin.try!(:extra_fields).to_json
    ]
  end

  def account_headers
    ["ID", "Status", "Group", "Country", "Plan Name", "Signup Date", "Number of Applications",
     "Admin", "E-mail", "User Specific Data (Account)", "User Specific Data (Admin)"]
  end

end

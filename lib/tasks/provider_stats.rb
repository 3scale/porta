require_dependency 'csv'

def days_since(time)
  return -1 if time.nil?
  ((Time.now - time.to_time) / 60 / 60 / 24).to_i
end

def last_admin_access_of(provider)
  provider.users.impersonation_admins.map{|u| u.user_sessions.last.try!(:accessed_at)}.compact.max
end

begin
  count = 1
  CSV.open("provider_stats.csv", "w") do |csv|
    headers = [
      "id", "org_name", "application plan", "email", "first_name last_name", "phone",
      "domain", "signup date", "is_custom", "days since creation of provider account",
      "days since the last buyer account was created", "days since last traffic was seen",
      "days since any of the CMS tables were modified", "days since last sign-in from provider",
      "days since last sign-in from buyers", "number of buyer accounts"
    ]

    #multitenant fields definitions
    definition_fields = Account.master.fields_definitions
    headers.concat definition_fields.map(&:label)

    csv << headers

    Account.providers.find_each(:batch_size => 5) do |p|
      row = []
      row << p.id
      row << p.org_name
      row << p.bought_plan.name
      row << p.emails.first
      row << "#{p.users.first.first_name} #{p.users.first.last_name}"
      row << p.billing_address_phone
      row << p.domain
      row << p.created_at
      row << ((p.domain && p.domain.ends_with?(".3scale.net")) ? "0" : "1")
      row << days_since(p.created_at)

      ## do the 3 rows that have to do with buyer_accounts in one traversal
      buyer_accounts_size = 0
      last_login_total = nil
      last_buyer_account = nil

      Account.send(:with_exclusive_scope) do
        p.buyer_accounts.find_each(:batch_size => 5) do |a|
          a.users.find_each(:batch_size => 5) do |u|
            if !u.user_sessions.empty?
              last_login_total ||= u.user_sessions.last.accessed_at
              last_login_total = u.user_sessions.last.accessed_at if u.user_sessions.last.accessed_at > last_login_total
            end
          end
          buyer_accounts_size+=1
          last_buyer_account = a
        end
      end

      row << days_since( ( last_buyer_account || p).created_at )
      row << days_since(TrafficService.build(p).last_traffic_date).to_i
      row << days_since( p.templates.sort_by{|c| c.updated_at}.last.try!(:updated_at) )
      row << days_since( last_admin_access_of(p) )
      #too much to just get the newer date
      #row << (days_since( p.buyer_accounts.map{|a| a.users }.flatten.reject{|u| u.last_login_at.nil? }.sort_by{|user| user.last_login_at }.last.try(:last_login_at)) || -1)
      row << days_since(last_login_total)
      row << buyer_accounts_size
      definition_fields.each { |field| row << p.extra_fields[field.name] }
      count+=1
      csv << row
    end
  end

  puts "Stats CSV successful. #{count} providers processed."

rescue Exception => e
  System::ErrorReporting.report_error(e, parameters: { human_explanation: "Stats for marketing failed CSV failed!", provider: p })
end

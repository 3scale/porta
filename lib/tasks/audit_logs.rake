# frozen_string_literal: true

namespace :audit_logs do

  desc "Audit logs generated by actions of admin users of buyer accounts under a given service ID"
  task :admin_actions, [:begin, :end, :service_id, :file_path] => [:environment] do |task, args|
    start_date = Time.zone.parse(args[:begin])
    end_date = Time.zone.parse(args[:end])

    service = Service.find(args[:service_id])
    admin_users = User.admins.where(account_id: service.contracts.select(:user_account_id).distinct)

    file_path = args[:file_path] || "#{task.name.sub(':', '__')}__#{Time.zone.now.strftime('%Y%m%d%H%M%S')}.csv"
    file_path = File.expand_path(file_path)

    audit_attributes = [
      :id,
      :created_at,
      :user_type,
      :user_id,
      :username,
      :remote_address,
      :auditable_type,
      :auditable_id,
      :action,
      :audited_changes
    ]

    SEPARATOR = ";"

    File.open(file_path, File::WRONLY | File::APPEND | File::CREAT) do |f|
      f.puts audit_attributes.join(SEPARATOR)

      Audited.audit_class.where(
        created_at: start_date..end_date,
        provider_id: service.account_id,
        #auditable_type: "User",
        user_type: "User",
        user_id: admin_users.select(:id)
      ).order(:created_at).includes(:user).find_each do |audit|
        audit_values = audit_attributes.collect { |attribute| attribute.eql?(:username) ? audit.user.username : audit.public_send(attribute) }
        f.puts audit_values.join(SEPARATOR)
      end
    end
  end

end

task :tenant, [:id] => [:environment] do |task, args|
  require 'hirb'

  tenant_id = args[:id]
  raise "You have to pass id" unless tenant_id

  connection = ActiveRecord::Base.connection
  connection.select_values("show tables").each do |table|
    columns = connection.select_values("show columns from #{table}")
    next unless columns.include?('tenant_id')

    rows = connection.select_rows("select * from #{table} where tenant_id = #{tenant_id}")
    next unless rows.present?

    rows.insert(0, columns)

    puts "# table: #{table}"
    puts Hirb::Helpers::AutoTable.render(rows)
  end
end

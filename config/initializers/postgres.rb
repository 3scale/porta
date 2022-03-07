# frozen_string_literal: true

ActiveSupport.on_load(:active_record) do
  if System::Database.postgres?
    ENV['SCHEMA'] = 'db/postgres_schema.rb'
  end
end

# frozen_string_literal: true

if System::Database.postgres?
  ENV['SCHEMA'] = 'db/postgres_schema.rb'
end

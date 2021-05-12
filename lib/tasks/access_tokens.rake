# frozen_string_literal: true

namespace :access_tokens do
  namespace :update do
    desc 'Update APIcast master access token'
    task :master_apicast, [:token] => :environment do |t, args|
      token_name = ENV.fetch('APICAST_TOKEN_NAME', 'APIcast mapping-service')
      error_message = %(Please execute with `rake "#{t.name}[$token_value]"` or `rake "#{t.name} TOKEN=''$token_value"`")
      token = args[:token] || ENV.fetch('TOKEN') { raise error_message }
      master = Account.master
      access_token = master.access_tokens.find_by!(name: token_name)
      # Need to do that because `:value` is a readonly attribute
      AccessToken.where(id: access_token.id).limit(1).update_all(value: token) # rubocop:disable Rails/SkipsModelValidations
    end
  end
end

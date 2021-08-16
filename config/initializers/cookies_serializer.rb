# Be sure to restart your server when you modify this file.

# Specify a serializer for the signed and encrypted cookie jars.
# Valid options are :json, :marshal, and :hybrid.
# TODO: switch this to :json, it's been :hybrid long enough
Rails.application.config.action_dispatch.cookies_serializer = :hybrid

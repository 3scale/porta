# frozen_string_literal: true

# This representer represents member permissions in a user-friendly way
# Examples:
# --------------------------------------------------
# XML:
# --------------------------------------------------
# <permissions>
#   <user_id>10</user_id>
#   <role>member</role>
#   <allowed_sections>
#     <admin_section>monitoring</admin_section>
#     <admin_section>portal</admin_section>
#     <admin_section>settings</admin_section>
#   </allowed_sections>
#   <allowed_service_ids>
#     <allowed_service_id>2</allowed_service_id>
#     <allowed_service_id>3</allowed_service_id>
#   </allowed_service_ids>
# </permissions>
# --------------------------------------------------
# JSON:
# --------------------------------------------------
# {
#   "permissions": {
#     "user_id": 10,
#     "role": "member",
#     "allowed_service_ids": [ 2, 3 ],
#     "allowed_sections": [ "monitoring", "portal", "settings" ],
#     "links": [{
#         "rel": "user",
#         "href": "http://provider-admin.3scale.net/admin/api/accounts/2/users/10"
#     }]
#   }
# }

class MemberPermissionsRepresenter < ThreeScale::Representer

  wraps_resource :permissions

  property :user_id, getter: ->(user_options:, **) { user_options[:user].id }
  property :role, getter: ->(user_options:, **) { user_options[:user].role }

  class JSON < MemberPermissionsRepresenter
    include Roar::JSON

    # NOTE: The list of allowed sections is sorted to facilitate acceptance testing, this is not part of the API specification
    property :allowed_sections, getter: ->(user_options:, **) { user_options[:user].allowed_sections&.sort }
    property :allowed_service_ids, getter: ->(user_options:, **) { user_options[:user].allowed_service_ids }, render_nil: true

    link :user do |opts|
      user = opts[:user]
      admin_api_account_user_url(user.account_id, user)
    end
  end

  class XML < MemberPermissionsRepresenter
    include Roar::XML
    wraps_resource :permissions

    # NOTE: The list of allowed sections is sorted to facilitate acceptance testing, this is not part of the API specification
    collection :allowed_sections, as: :allowed_section, wrap: :allowed_sections, getter: ->(user_options:, **) { user_options[:user].allowed_sections&.sort }
    collection :allowed_service_ids, as: :allowed_service_id, wrap: :allowed_service_ids, getter: ->(user_options:, **) { user_options[:user].allowed_service_ids }
  end

end

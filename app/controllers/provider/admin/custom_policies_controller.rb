#frozen_string_literal: true

class Provider::Admin::CustomPoliciesController < Provider::Admin::BaseController
  before_action :find_service
  before_action :find_proxy

  activate_menu :account, :integrate, :policies

  layout 'provider'

  def index
    @policies = { # sample data
      'apicast' => [{'name'=> 'Apicast', 'summary'=> 'Apicast summary', 'description'=> 'Apicast description', 'version'=> '1.0.0', 'schema'=> {}, 'configuration'=> {}}],
      'cors' => [{'name'=> 'CORS', 'summary'=> 'CORS summary', 'description'=> 'CORS headers', 'version'=> '1.0.0', 'schema'=> {}, 'configuration'=> {}}],
      'echo'=> [{'name'=> 'Echo', 'summary'=> 'Echo summary', 'description'=> 'Echoes the request', 'version'=> '1.0.0', 'schema'=> {}, 'configuration'=> {}}],
      'headers' => [{'name'=> 'Headers', 'summary'=> 'Headers summary', 'description'=> 'Allows setting Headers', 'version'=> '1.0.0', 'schema'=> {}, 'configuration'=> {}}]
    }

  end

  def edit
    @policy = {
      'echo': {
        'name': 'Echo', 'summary': 'Echo summary', 'description': 'Echoes the request', 'version': '1.0.0', '$schema': {}, 'schema': {},
        'configuration': {
          'title': 'Custom Policy',
          'description': 'An epic policy yet to code.',
          'type': 'object',
          'required': [
              'name'
          ],
          'properties': {
            'name': {
              'type': 'string',
              'title': 'Name',
              'default': 'Mashing'
            },
            'version': {
              'type': 'integer',
              'title': 'Version',
              'default': 1
            }
          }
        }
      }
    }
  end

  protected

  def find_proxy
    @proxy = @service.proxy
  end

end

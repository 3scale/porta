require 'yaml'
require 'json'
require 'uri'
require 'time'
require 'net/http'
require 'pathname'

TEMPLATE = 'https://raw.githubusercontent.com/3scale/3scale-operator/master/pkg/3scale/amp/auto-generated-templates/amp/amp-eval.yml'

def read_url(resource)
  Net::HTTP.get(URI.parse(resource))
end

def system_dc(template)
  dc = template.fetch('objects').find do |obj|
    obj.fetch('kind') == 'DeploymentConfig' && obj.dig('metadata', 'name') == 'system-app'
  end
  raise "system deployment config not found from #{TEMPLATE}" if dc.nil?

  dc
end

def pre_hook(template)
  system_dc(template).dig('spec', 'strategy', 'rollingParams', 'pre')
end

def pre_hook_command(template)
  pre_hook(template).dig('execNewPod', 'command')
end

def pre_hook_env(template)
  pre_hook(template).dig('execNewPod', 'env')
end

POD_NAME = ARGV[0]
IMAGE = ARGV[1]

amp_template = YAML.safe_load(read_url(TEMPLATE))

pod_template = {
  apiVersion: 'v1',
  spec: {
    containers: [
      {
        name: POD_NAME,
        image: IMAGE,
        tty: true,
        command: pre_hook_command(amp_template),
        env: pre_hook_env(amp_template)
      }
    ]
  }
}

puts pod_template.to_json

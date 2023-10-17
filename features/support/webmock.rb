require 'webmock/cucumber'
WebMock.disable_net_connect!(allow_localhost: true, allow: [/\.example\.com/, /\.3scale\.localhost/, /__identify__/], net_http_connect_on_start: true)

require 'fakeweb'
FakeWeb.allow_net_connect = true

require 'webmock/cucumber'
WebMock.disable_net_connect!(allow_localhost: true,
                             allow: [/\.example\.com/, /__identify__/, 'percy.io'])

# Memory needed presently to compile js/ts is aroung 2.5GB
# This initializer affects rails server in dev mode as well webpack-dev-server
# Interesting enough rake assets:precompile doesn't appear to need it
unless "#{ENV['NODE_OPTIONS']}".include? "--max-old-space-size"
  Webpacker::Compiler.env['NODE_OPTIONS'] = "#{ENV['NODE_OPTIONS']} --max-old-space-size=2560"
end

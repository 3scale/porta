# frozen_string_literal: true

Given "URL is inaccessible in browser: {string}" do |url|
  assert_match /:(?:\d+)\b/, url, "specify port in URL because of Capybara.always_include_port"

  available = true

  begin
    visit url
  rescue => e
    available = false
    puts "URL inaccessible in browser with: #{e.inspect}"
  end

  assert_not available, "URL should not be accessible but is."
end

Given "URL is inaccessible in ruby: {string}" do |url|
  available = true

  begin
    URI.open(url) {}
  rescue WebMock::NetConnectNotAllowedError, StandardError => e
    available = false
    puts "URL inaccessible in Ruby: #{e.inspect}"
  end

  assert_not available, "URL should not be accessible in Ruby but is."
end

Given "hostname is not resolvable: {string}" do |hostname|
  res = Socket.getaddrinfo(hostname, 0, Socket::AF_INET, Socket::SOCK_STREAM, nil, Socket::AI_CANONNAME)
  log_string = res.map { |r| r[3] }.join(",")

  raise "#{hostname} resolved to: #{log_string}" if res.size > 1 || res.size == 1 && !res.first[3].start_with?("127.")

  puts "#{hostname} resolved to: #{log_string}"
end

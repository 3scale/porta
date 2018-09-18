# frozen_string_literal: true

When(/^(?:|I )open an URL with XSS exploit$/) do
  params = {
    metric_name: 'hits',
    since: Time.zone.now.to_date.to_s,
    until: Time.zone.now.to_date.to_s,
    format: :html
  }
  url = path_to('the buyer stats usage page', params)

  granularity = "123%3Cimg%20src%3d%271%27%20onerror%3d%27confirm%28%2fXSS%2f%29%27%3E"
  url = "#{url}&granularity=#{granularity}"

  visit url
end

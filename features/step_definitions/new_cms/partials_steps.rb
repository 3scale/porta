Then /^(CMS Partial ".+?") should have:/ do |page, table|
  table = table.transpose
  actual = table.headers.map do |header|

    header = header.parameterize('_').to_sym
    value = page.send(header)
    value.to_s
  end

  table.diff! [table.headers, actual]
end

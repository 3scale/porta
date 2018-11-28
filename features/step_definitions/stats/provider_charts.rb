Then(/^there should be a c3 chart with the following data:$/) do |table|
  chart_selector = '.c3'

  page.should have_css(chart_selector)
  page.should have_css(chart_selector + '.c3')
  page.should_not have_css(chart_selector + '.is-loading')

  table.map_column!('total', &:to_i)
  page.document.synchronize(Capybara.default_max_wait_time,
                            errors: [Cucumber::Ast::Table::Different, Selenium::WebDriver::Error::JavascriptError]) do
    values = page.evaluate_script <<-JS
      (function(){
        var $chart = $("#{chart_selector}")
        var series = $chart.data().chart.data()
        var values = series.map(function(s){
          return {
            name: s.id,
            total: s.values.map(val => val.value).reduce((previous, current) => previous + current, 0)
          }
        })
        return values
      }());
    JS

    raise Selenium::WebDriver::Error::JavascriptError, 'Could not get values from c3' if values.blank?

    data = Cucumber::Core::Ast::DataTable.new(values, table.location)
    series = Cucumber::Ast::Table.new(data)
    series.map_column!('start', false) { |start| Time.at(start/1000) if start }

    table.dup.diff!(series)
  end
end

Then(/^testing the analytics chart$/) do
  page.document.synchronize(Capybara.default_max_wait_time,
                            errors: [Cucumber::Ast::Table::Different, Selenium::WebDriver::Error::JavascriptError]) do
    values = page.evaluate_script <<-JS
      (function(){
        var $chart = $('#mini-charts > .charts')
        var series = $chart.data().chart.data()
        var values = series.map(function(s){
          return {
            name: s.id,
            total: s.values.map(val => val.value).reduce((previous, current) => previous + current, 0)
          }
        })
        return values
      }());
    JS
    pp values
  end
end

When(/^I select today from the stats menu$/) do
  page.should_not have_css('.StatsChart-container.is-loading')
  page.should have_css('.StatsMenu')
  find('.StatsMenu-customLink--since').click
  find('.ui-datepicker-today').click
end

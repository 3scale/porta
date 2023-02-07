# -*- coding: utf-8 -*-
module Alerts

  def create_alert!(cinstance, hash)
    attributes = hash.slice(:timestamp, :message, :utilization, :level, :alert_id).merge(
      :cinstance => cinstance
    )

    Alert.create! [ attributes.merge(:account => cinstance.user_account),
                    attributes.merge(:account => cinstance.service.account) ]
  end

  def limit_alerts_table(state = nil)
    scope = 'tr'
    scope << "[data-state='#{state}']" if state.present?
    scope << "[id*='alert']"

    states = all("#limit_alerts tbody #{scope}")
    table = extract_table("#limit_alerts", "thead tr:not(.search), tbody #{scope}", "th, td")
    table.first << 'State'
    states.each_with_index do |tr, index|
      table[index + 1] << tr['data-state']
    end

    data = Cucumber::Core::Test::DataTable.new(table)

    table = Cucumber::MultilineArgument::DataTable.new data

    # two byte non breaking space :/
    nbsp = ' '
    table.map_column('Level') {|level| level.gsub(nbsp, ' ') }
  end

end

World(Alerts)

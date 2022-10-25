// @flow

import * as React from 'react'
import { useState, useEffect } from 'react'

import { createReactWrapper } from 'utilities'
import { render as renderChartWidget } from 'Dashboard/chart'
import { Spinner } from 'Common'

type ChartValues = {
  value: number,
  formatted_value: string
}

type ChartValuesByDate = {
  [key: string]: ChartValues
}

type ChartData = {
  values: ChartValuesByDate,
  complete?: ChartValuesByDate,
  incomplete?: ChartValuesByDate,
  previous?: ChartValuesByDate
}

type PreviousRangeAdminBuyersAccount = {
  url: string,
  value: string
}

type CurrentRangeAdminBuyersAccount = {
  url: string
}

type LastDayInRangeAdminBuyersAccount = {
  url: string,
  value: string
}

type Links = {
  previousRangeAdminBuyersAccount: PreviousRangeAdminBuyersAccount,
  currentRangeAdminBuyersAccount: CurrentRangeAdminBuyersAccount,
  lastDayInRangeAdminBuyersAccount: LastDayInRangeAdminBuyersAccount
}

export type Props = {
  chartData: ChartData,
  newAccountsTotal: number,
  hasHistory: boolean,
  links: Links,
  percentualChange: number
}

const NewAccountsWidgetTitle = ({ currentRangeAdminBuyersAccount, newAccountsTotal }: { currentRangeAdminBuyersAccount: CurrentRangeAdminBuyersAccount, newAccountsTotal: number }) => (
  <h1 className="DashboardWidget-title">
    <a className="DashboardWidget-link" href={currentRangeAdminBuyersAccount.url}>
      <strong data-title-count="true">{newAccountsTotal}</strong> Signups
    </a>
  </h1>
)

const NewAccountsWidgetPercentageInfo = ({ hasHistory, percentualChange, previousRangeAdminBuyersAccount, lastDayInRangeAdminBuyersAccount }: { hasHistory: boolean, percentualChange: number, previousRangeAdminBuyersAccount: PreviousRangeAdminBuyersAccount, lastDayInRangeAdminBuyersAccount: LastDayInRangeAdminBuyersAccount }) => (
  <div className="DashboardWidget-percentageInfo" data-toggle-visibility="true">
    {
      hasHistory
        ? <a href={previousRangeAdminBuyersAccount.url} className={`DashboardWidget-link ${percentualChange > 0 ? 'u-plus' : 'u-minus' }`}>
            {previousRangeAdminBuyersAccount.value}
          </a>
        : <a href={lastDayInRangeAdminBuyersAccount.url} className="DashboardWidget-link DashboardWidget-link--today">
            {lastDayInRangeAdminBuyersAccount.value}
          </a>
    }
    <span className="DashboardWidget-intro DashboardWidget-intro--primary" data-title-intro="true">
      last 30 days
    </span>
    <span className="DashboardWidget-intro DashboardWidget-intro--secondary" data-toggle-visibility="true">
      {hasHistory ? 'vs. previous 30 days' : 'today'}
    </span>
  </div>
)

const NewAccountsWidget = ({ chartData, newAccountsTotal, hasHistory, links, percentualChange }: Props): React.Node => {
  const [isLoading, setIsLoading] = useState(true)

  useEffect(() => {
    renderChartWidget(document.getElementById('dashboard-widget-new_accounts'), chartData)
    setIsLoading(false)
  }, [])

  return (
    <article className="DashboardWidget" id="dashboard-widget-new_accounts">
      {isLoading && <Spinner size="md" isSVG className="pf-u-ml-md DashboardWidget-spinner" />}
      <div className="Dashboard-chart c3" data-chart/>
      <header className="DashboardWidget-badge">
        <NewAccountsWidgetTitle
          currentRangeAdminBuyersAccount={links.currentRangeAdminBuyersAccount}
          newAccountsTotal={newAccountsTotal}
        />
        <NewAccountsWidgetPercentageInfo
          hasHistory={hasHistory}
          percentualChange={percentualChange}
          previousRangeAdminBuyersAccount={links.previousRangeAdminBuyersAccount}
          lastDayInRangeAdminBuyersAccount={links.lastDayInRangeAdminBuyersAccount}
        />
      </header>
    </article>
  )
}

const NewAccountsWidgetWrapper = (props: Props, containerId: string): void => createReactWrapper(<NewAccountsWidget {...props} />, containerId)

export { NewAccountsWidget, NewAccountsWidgetWrapper }

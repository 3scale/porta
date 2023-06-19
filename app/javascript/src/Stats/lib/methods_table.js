/** @jsx StatsUI.dom */
import moment from 'moment-timezone'
import numeral from 'numeral'

import { StatsUI } from 'Stats/lib/ui'

const TIMESTAMP_FORMAT = 'DD MMM YYYY HH:mm:ss zz'

export class StatsMethodsTable extends StatsUI {
  constructor ({ container }) {
    super({ container })
    this.data = []
  }

  template () {
    let chartTable = this
    let methodsDetails = this.data

    return (
      <table id="methods_table" className={`data StatsMethodsTable ${chartTable._tableVisibility()}`}>
        <thead>
          <tr>
            <th>Method</th>
            <th>From</th>
            <th>To</th>
            <th>Traffic</th>
          </tr>
        </thead>
        <tbody>
          {
            methodsDetails.map(methodDetails =>
              [
                <tr>
                  <td className={`StatsMethodsTable-name ${this._isMetricHits(methodDetails) ? '' : 'is-children'}`}>
                    {methodDetails.name}
                  </td>
                  <td className="StatsMethodsTable-since">
                    {moment.tz(methodDetails.period.since, methodDetails.period.timezone).format(TIMESTAMP_FORMAT)}
                  </td>
                  <td className="StatsMethodsTable-until">
                    {moment.tz(methodDetails.period.until, methodDetails.period.timezone).format(TIMESTAMP_FORMAT)}
                  </td>
                  <td className="StatsMethodsTable-total u-amount u-tabular-number">
                    {numeral(methodDetails.total).format('0,0').toUpperCase()}
                  </td>
                </tr>
              ]
            )
          }
        </tbody>
      </table>

    )
  }

  update (data) {
    this.data = data._methodsTableData
    this.refresh()
  }

  _tableVisibility () {
    return (this.data.length > 1) ? 'is-visible' : 'is-hidden'
  }

  _isMetricHits (methodDetails) {
    return methodDetails.systemName === 'hits'
  }

  _bindEvents () {

  }
}

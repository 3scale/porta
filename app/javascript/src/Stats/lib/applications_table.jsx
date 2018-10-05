/** @jsx StatsUI.dom */
import numeral from 'numeral'

import {StatsUI} from './ui'

export class StatsApplicationsTable extends StatsUI {
  constructor ({container}) {
    super({container})
    this.data = []
  }

  template () {
    let applicationsTable = this
    let applicationsDetails = this.data

    return (
      <table id='applications_table' className={`data StatsTable ${applicationsTable._tableVisibility()}`}>
        <thead>
        <tr>
          <th>Application</th>
          <th>Account</th>
          <th>Traffic</th>
        </tr>
        </thead>
        <tbody>
        {
          applicationsDetails.map(details =>
            [
              <tr>
                <td>
                  <a className="StatsApplicationsTable-application" href={details.application.link}>{details.application.name}</a>
                </td>
                <td>
                  <a className="StatsApplicationsTable-account" href={details.account.link}>{details.account.name}</a>
                </td>
                <td className="StatsApplicationsTable-total u-amount u-tabular-number">
                  {numeral(details.total).format('0,0').toUpperCase()}
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
    this.data = this._orderDetails(data._applicationDetails)
    this.refresh()
  }

  _orderDetails (details) {
    return details.sort((a, b) => b.total - a.total)
  }

  _tableVisibility () {
    return (this.data.length > 1) ? 'is-visible' : 'is-hidden'
  }

  _bindEvents () {}
}

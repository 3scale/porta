/** @jsx StatsUI.dom */
import moment from 'moment'
import 'moment-timezone'

import {StatsUI} from 'Stats/lib/ui'

const TIMESTAMP_FORMAT = 'DD MMM YYYY HH:mm:ss zz'

export class StatsCSVLink extends StatsUI {
  constructor ({container}) {
    super({container})
    this.csvString = ''
  }

  template () {
    let csvString = this.csvString

    return (
      <a className="StatsCSVLink" href={`data:attachment/csv,${csvString}`} target='_blank' download='data.csv'>Download CSV</a>
    )
  }

  update (data) {
    this.csvString = this.buildCSVString(data)
    this.refresh()
  }

  buildCSVString (data) {
    let csvMatrix = this._parseData(data)
    return csvMatrix.map(cell => cell.join(',')).join('%0A')
  }

  _parseData (data) {
    this.data = data
    let columns = data.columns.map(column => column.slice())
    columns = this._parseTimeColumn(columns)
    let columnLength = columns[0].length
    let csvMatrix = []
    let csvCell = []
    let j = 0
    do {
      j++
      csvCell = []
      for (let column of columns) {
        csvCell.push(column.shift())
      }
      csvMatrix.push(csvCell)
    } while (j < columnLength)
    return csvMatrix
  }

  _parseTimeColumn (columns) {
    columns[0] = columns[0].map((value, key) => (key > 0) ? moment(value).utc().tz(this.data._period.timezone).format(TIMESTAMP_FORMAT) : 'datetime')
    return columns
  }

  _bindEvents () {

  }
}

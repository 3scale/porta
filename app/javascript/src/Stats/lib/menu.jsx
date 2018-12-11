/** @jsx StatsUI.dom */

import 'core-js/fn/object/assign' // make Object.assign on IE 11
import pluralize from 'pluralize'
import $ from 'jquery'
import 'jquery-ui/ui/widgets/datepicker'

import * as helpers from 'Stats/lib/stats_helpers'
import {StatsUI} from 'Stats/lib/ui'
import {CustomRangeDate, PeriodRangeDate} from 'Stats/lib/state'

class Hook {

  constructor (options) {
    this.options = options
  }

  hook (elem, hook) {
    this.datepicker = $(elem).datepicker(
      Object.assign({}, this.options)
    )
  }

  unhook () {
    this.datepicker.datepicker('destroy')
  }

  open () {
    this.datepicker.datepicker('show')
  }

}

export class StatsMenu extends StatsUI {
  constructor ({statsState, periods, granularities = ['hour', 'day', 'month'], container}) {
    super({statsState, container})
    this.periods = periods
    this.graularities = granularities
  }

  template () {
    let statsState = this.statsState

    let sinceDateHook = new Hook({
      dateFormat: 'yy-mm-dd',
      maxDate: new Date(statsState.state.dateRange.until),
      onSelect: date => {
        let dateRange = statsState.state.dateRange
        let selectedDate = new CustomRangeDate({
          Since: dateRange.since, Until: dateRange.until, granularity: dateRange.granularity
        })
        selectedDate.since = date
        statsState.setState({ dateRange: selectedDate })
      }
    })

    let untilDateHook = new Hook({
      dateFormat: 'yy-mm-dd',
      minDate: new Date(statsState.state.dateRange.since),
      onSelect: date => {
        let dateRange = statsState.state.dateRange
        let selectedDate = new CustomRangeDate({
          Since: dateRange.since, Until: dateRange.until, granularity: dateRange.granularity
        })
        selectedDate.until = date
        statsState.setState({ dateRange: selectedDate })
      }
    })

    return (
      <div className='StatsMenu'>
        <span>Show last</span>
        <ol className='StatsMenu-period'>
          { this.periods.map(period =>
            <li className='StatsMenu-periodItem'>
              <a className={`StatsMenu-Link StatsMenu-periodLink period-${period.number}-${period.unit}
                                  ${JSON.stringify(period) === JSON.stringify(statsState.state.dateRange.period)
                                    ? 'is-selected' : ''}`}
                 attributes={{'data-number': period.number, 'data-unit': period.unit}}
                 onclick={ ev => statsState.setState({dateRange: new PeriodRangeDate(period)})}>
                {`${period.number} ${pluralize.plural(period.unit)}`}
              </a>
            </li>
          )}
        </ol>
        <div className='StatsMenu-custom'>
          <span>
            {' from '}
            <input className='StatsMenu-customInput' sinceDateHook={sinceDateHook} type='text'></input>
            <a className='StatsMenu-Link StatsMenu-customLink StatsMenu-customLink--since'
               onclick={ev => sinceDateHook.open()}>{helpers.humanDateFormat(statsState.state.dateRange.since)}</a>
          </span>
          <span>
            {' until '}
            <input className='StatsMenu-customInput' untilDateHook={untilDateHook} type='text'></input>
            <a className='StatsMenu-Link StatsMenu-customLink StatsMenu-customLink--until'
               onclick={ev => untilDateHook.open()}>{helpers.humanDateFormat(statsState.state.dateRange.until)}</a>
          </span>
          <span>
          {' per '}
            <a
              className='StatsMenu-Link'
              style={{display: this.show_granularity ? 'none' : 'inline-block'}}
              onclick={ev => {
                this.show_granularity = true
                this.refresh()
              }}> {statsState.state.dateRange.granularity} </a>
            <select
              style={{ display: this.show_granularity ? 'inline-block' : 'none' }}
              onchange={ev => {
                this.show_granularity = false
                let date = new CustomRangeDate(statsState.state.dateRange)
                date.granularity = ev.target.value
                statsState.setState({dateRange: date})
              }}>
              {this.graularities.map(granularity =>
                <option value={granularity}
                        attributes={statsState.state.dateRange.granularity === granularity ? { selected: true } : {}}>
                  {granularity}
                </option>
              )}
            </select>
          </span>

        </div>
      </div>
    )
  }

}

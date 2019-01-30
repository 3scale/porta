/** @jsx StatsUI.dom */
import {StatsUI} from 'Stats/lib/ui'
import $ from 'jquery'

const DEFAULT_METRIC = 'hits'

export class StatsApplicationsSelector extends StatsUI {
  constructor ({statsState, applicationGroups, container}) {
    super({statsState, container})
    this.applicationGroups = applicationGroups

    this.selectApplication = this.selectApplication.bind(this)
  }

  render () {
    this._removeOriginalSelector()
    super.render()
  }

  template () {
    let applicationGroups = this.applicationGroups
    let serviceNames = Object.keys(applicationGroups)
    let selectedApplicationId = this._selectedApplicationId(applicationGroups, serviceNames[0])
    let groupTemplate = this._groupTemplate(serviceNames, applicationGroups, selectedApplicationId)

    return (
      <select onchange={this.selectApplication} value={selectedApplicationId} className="StatsApplicationSelector">
        {groupTemplate}
      </select>
    )
  }

  selectApplication (event) {
    let applicationId = $(event.target).val()
    this._setState({selectedApplicationId: applicationId, selectedMetricName: DEFAULT_METRIC}, ['applicationSelected'])
  }

  _removeOriginalSelector () {
    $(this.container).html('')
  }

  _selectedApplicationId (applicationGroups, serviceName) {
    return Number.parseInt(this.statsState.state.selectedApplicationId, 10) || Number.parseInt(applicationGroups[serviceName][0].id, 10)
  }

  _groupTemplate (serviceNames, applicationGroups, selectedApplicationId) {
    return (
      serviceNames.map(serviceName =>
        <optgroup label={serviceName}>
          {
            applicationGroups[serviceName].map(application =>
              [
                <option value={application.id}
                  selected={selectedApplicationId === application.id}
                >{application.name}</option>
              ]
            )
          }
        </optgroup>
      )
    )
  }
}

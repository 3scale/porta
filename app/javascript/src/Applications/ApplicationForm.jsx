import React from 'react'
import { SearchableSelect } from '../Common/SearchableSelect'

class ApplicationForm extends React.Component {
  state = {
    appPlan: this.props.appPlans[0],
    name: '',
    description: ''
  }

  onAppPlanChange (appPlan) {
    this.setState({ appPlan })
  }

  onInputChange (event) {
    this.setState({ name: event.currentTarget.value })
  }

  onDescriptionChange (event) {
    this.setState({ description: event.currentTarget.value })
  }

  render () {
    const { appPlans } = this.props
    const { appPlan, name, description } = this.state

    return (
      <React.Fragment>
        <li id='cinstance_plan_input' className='select required'>
          <SearchableSelect options={appPlans} label='Application plan' formId='cinstance_plan_id' formName='cinstance[plan_id]' onOptionSelect={appPlan => this.onAppPlanChange(appPlan)} />
        </li>
        <li id='cinstance_service_plan_id_input' className='select optional'>
          <SearchableSelect options={appPlan.servicePlans} label='Service plan' formId='cinstance_service_plan_id' formName='cinstance[service_plan_id]' />
        </li>
        <li id='cinstance_name_input' className='string required'>
          <label htmlFor="cinstance_name">Name</label>
          <input maxLength="255" id="cinstance_name" type="text" name="cinstance[name]" value={name} onChange={e => this.onInputChange(e)} />
        </li>
        <li id='cinstance_description_input' className='text required'>
          <label htmlFor="cinstance_description">Description</label>
          <textarea rows="20" id="cinstance_description" name="cinstance[description]" value={description} onChange={e => this.onDescriptionChange(e)} />
        </li>
      </React.Fragment>
    )
  }
}

export { ApplicationForm }

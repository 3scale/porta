import 'core-js/es6/map'
import 'core-js/es6/set'

import React from 'react'
import ReactDOM from 'react-dom'
import { ApplicationForm } from '../src/Applications/ApplicationForm'

document.addEventListener('DOMContentLoaded', () => {
  var dataset = document.getElementById('metadata-form').dataset
  var appPlans = JSON.parse(dataset.applicationPlans)

  document.getElementById('cinstance_plan_input').remove()
  document.getElementById('cinstance_service_plan_id_input').remove()

  ReactDOM.render(
    <ApplicationForm appPlans={appPlans} />,
    document.querySelector('fieldset.inputs > ol')
  )
})

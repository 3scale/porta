import React from 'react'
import ReactDOM from 'react-dom'
import { ApplicationForm } from 'Applications/ApplicationForm'

document.addEventListener('DOMContentLoaded', () => {
  const applicationPlans = JSON.parse(document.getElementById('metadata-form').dataset.applicationPlans)
  const servicePlansAllowed = JSON.parse(document.getElementById('metadata-form').dataset.servicePlansAllowed)

  // Fieldset container
  const form = document.querySelector('.inputs > ol')

  // Remove vanilla selects
  document.getElementById('cinstance_plan_input').remove()
  document.getElementById('cinstance_service_plan_id_input').remove()

  // Create React selects
  const container = document.createElement('div')
  form.prepend(container)
  ReactDOM.render(<ApplicationForm applicationPlans={applicationPlans} servicePlansAllowed={servicePlansAllowed} />, container)

  // Move selects
  form.prepend(document.getElementById('cinstance_service_plan_id_input'))
  form.prepend(document.getElementById('cinstance_plan_input'))

  // Clean temp element
  container.remove()
})

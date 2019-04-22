import React from 'react'
import ReactDOM from 'react-dom'
import { ApplicationForm } from 'Applications/ApplicationForm'

document.addEventListener('DOMContentLoaded', () => {
  console.log(document.getElementById('metadata-form').dataset)
  const applicationPlans = JSON.parse(document.getElementById('metadata-form').dataset.applicationPlans)
  const servicePlansAllowed = JSON.parse(document.getElementById('metadata-form').dataset.servicePlansAllowed)
  const container = document.getElementById('application-form')

  ReactDOM.render(<ApplicationForm applicationPlans={applicationPlans} servicePlansAllowed={servicePlansAllowed} />, container)
})

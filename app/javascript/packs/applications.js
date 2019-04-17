import React from 'react'
import ReactDOM from 'react-dom'
import { ApplicationForm } from 'Applications/ApplicationForm'

document.addEventListener('DOMContentLoaded', () => {
  const applicationPlans = JSON.parse(document.getElementById('metadata-form').dataset.applicationPlans)
  const container = document.getElementById('applications-form')

  ReactDOM.render(<ApplicationForm applicationPlans={applicationPlans} />, container)
})

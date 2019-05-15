import { initialize as planSelector } from 'Applications/plan_selector'
import { CreateApplication } from 'Applications/create_application'

document.addEventListener('DOMContentLoaded', () => {
  planSelector()
  window.createApplication = new CreateApplication()
})

import {render} from 'react-dom'
import React from 'react'
import {PolicyList} from 'Policies/components/PolicyList'

// Sample Policies
const policies = [
  {id: 1, name: 'apicast', humanName: 'Apicast', summary: 'Apicast summary', description: 'Apicast description', version: '1.0.0', schema: {}, configuration: {}},
  {id: 2, name: 'cors', humanName: 'CORS', summary: 'CORS summary', description: 'CORS headers', version: '1.0.0', schema: {}, configuration: {}},
  {id: 3, name: 'echo', humanName: 'Echo', summary: 'Echo summary', description: 'Echoes the request', version: '1.0.0', schema: {}, configuration: {}},
  {id: 4, name: 'headers', humanName: 'Headers', summary: 'Headers summary', description: 'Allows setting Headers', version: '1.0.0', schema: {}, configuration: {}}
]
document.addEventListener('DOMContentLoaded', () => {
  const container = document.getElementById('custom-policies-container')
  render(<PolicyList items={policies} />, container)
})

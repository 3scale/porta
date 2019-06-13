import React from 'react'
import { render } from 'react-dom'
import Header from '../src/Navigation/pageHeader'

document.addEventListener('DOMContentLoaded', () => {
  const headerElement = document.getElementById('headerPF4')
  const props = {
    href: headerElement.dataset.href
  }
  render(<Header {...props}/>, headerElement)
})

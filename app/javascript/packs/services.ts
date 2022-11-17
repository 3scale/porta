import { initialize as serviceInitialize } from 'services/index'

document.addEventListener('DOMContentLoaded', () => {
  window.serviceInitialize = serviceInitialize
})

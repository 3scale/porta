import { initialize as serviceInitialize } from '../src/services/index'

document.addEventListener('DOMContentLoaded', () => {
  window.serviceInitialize = serviceInitialize
})

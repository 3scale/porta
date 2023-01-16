document.addEventListener('DOMContentLoaded', () => {
  const containerId = 'use-example-api'
  const useExampleLink = document.getElementById(containerId)

  if (!useExampleLink) {
    throw new Error('The target ID was not found: ' + containerId)
  }

  const { url = '' } = useExampleLink.dataset

  const nameInput = document.getElementById('backend_api_name') as HTMLInputElement
  const urlInput = document.getElementById('backend_api_private_endpoint') as HTMLInputElement

  useExampleLink.addEventListener('click', e => {
    if (!nameInput.value) {
      nameInput.setAttribute('value', 'Echo API')
    }
    urlInput.setAttribute('value', url)

    e.preventDefault()
  })

  window.analytics.trackLink(useExampleLink, 'Clicked Example API Link')
})

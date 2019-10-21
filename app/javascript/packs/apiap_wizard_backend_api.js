document.addEventListener('DOMContentLoaded', () => {
  const useExampleLink = document.getElementById('use-example-api')
  const { url } = useExampleLink.dataset

  const nameInput = document.getElementById('backend_api_name')
  const urlInput = document.getElementById('backend_api_private_endpoint')

  useExampleLink.addEventListener('click', e => {
    if (!nameInput.value) {
      nameInput.setAttribute('value', 'Echo API')
    }
    urlInput.setAttribute('value', url)

    e.preventDefault()
  })

  window.analytics.trackLink(useExampleLink, 'Clicked Example API Link')
})

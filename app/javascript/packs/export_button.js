document.addEventListener('DOMContentLoaded', () => {
  const button = document.getElementById('ExportButton')
  const { url } = button.dataset

  button.addEventListener('click', () => {
    window.location.href = url
  })
})

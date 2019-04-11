import {fetch as fetchPolyfill} from 'whatwg-fetch'

document.addEventListener('DOMContentLoaded', () => {
  const BASE_URL = '/p/admin/service_discovery/'
  const formSource = document.getElementById('new_service_source')
  const formScratch = document.querySelectorAll('form#new_service, form#create_service')[0]
  const formDiscover = document.getElementById('service_discovery')

  const clearSelectOptions = select => {
    const options = select.getElementsByTagName('option')
    for (let option of options) {
      option.remove()
    }
  }

  const clearNamespaces = () => clearSelectOptions(formDiscover.service_namespace)

  const clearServiceNames = () => clearSelectOptions(formDiscover.service_name)

  const showAndHideForms = (showForm, hideForm) => {
    showForm.classList.remove('is-hidden')
    hideForm.classList.add('is-hidden')
  }

  const showServiceForm = (source, discoverFunc, scratchFunc) => {
    if (source === 'discover') {
      showAndHideForms(formDiscover, formScratch)
      if (typeof discoverFunc === 'function') {
        discoverFunc()
      }
    } else {
      showAndHideForms(formScratch, formDiscover)
      if (typeof scratchFunc === 'function') {
        scratchFunc()
      }
    }
  }

  const changeServiceSource = () => {
    clearNamespaces()
    clearServiceNames()
    showServiceForm(formSource.source.value, fetchNamespaces)
  }

  const changeClusterNamespace = () => {
    clearServiceNames()
    const indexSelected = formDiscover.service_namespace.selectedIndex
    formDiscover.service_namespace.setAttribute('data-selected-value', formDiscover.service_namespace[indexSelected].value)
    fetchServices()
  }

  const addOptionToSelect = (selectElem, val) => {
    const opt = document.createElement('option')
    opt.text = val
    return selectElem.appendChild(opt)
  }

  const fetchData = (url, type) => {
    fetchPolyfill(url)
      .then(response => {
        if (!response.ok) {
          throw Error(response.statusText)
        }
        return response.json()
      })
      .then(data => populateOptions(type, data))
      .catch(error => console.error(error))
  }

  const populateOptions = (type, data) => {
    switch (type) {
      case 'namespaces':
        populateNamespaces(data.projects)
        break
      case 'services':
        populateServices(data.services)
        break
    }
  }

  const populateNamespaces = projects => {
    if (projects.length > 0) {
      projects.forEach(
        project => addOptionToSelect(formDiscover.service_namespace, project.metadata.name)
      )
      changeClusterNamespace()
    }
  }

  const fetchNamespaces = () => fetchData(`${BASE_URL}projects.json`, 'namespaces')

  const populateServices = services => {
    services.forEach(
      service => addOptionToSelect(formDiscover.service_name, service.metadata.name)
    )
  }

  const fetchServices = () => {
    const selectedNamespace = formDiscover.service_namespace.dataset.selectedValue
    if (selectedNamespace !== '') {
      const URLServices = `${BASE_URL}namespaces/${selectedNamespace}/services.json`
      fetchData(URLServices, 'services')
    }
  }

  if (formSource !== null) {
    const radioGroup = formSource.source
    radioGroup.forEach(
      radio => radio.addEventListener('click', changeServiceSource)
    )
  }

  if (formDiscover !== null) {
    formDiscover.service_namespace.addEventListener('change', changeClusterNamespace)
  }
})

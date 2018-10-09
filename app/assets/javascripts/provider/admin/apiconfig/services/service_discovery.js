document.addEventListener("DOMContentLoaded", (e) => {

  const formSource = document.getElementById('new_service_source');
  const formScratch = document.querySelectorAll('form#new_service, form#create_service')[0];
  const formDiscover = document.getElementById('service_discovery');

  const clearSelectOptions = select => {
    const options = select.getElementsByTagName('option');
    for (let i = options.length -1; i > 0; i--) {
      options[i].remove()
    }
  };

  const clearNamespaces = () => {
    return clearSelectOptions(formDiscover.service_namespace);
  };

  const clearServiceNames = () => {
    return clearSelectOptions(formDiscover.service_name);
  };

  const showServiceForm = (source, discoverFunc, scratchFunc) => {
    if (source === 'discover') {
      formScratch.classList.add('is-hidden');
      formDiscover.classList.remove('is-hidden');
      return typeof discoverFunc === "function" ? discoverFunc() : undefined;
    } else {
      formScratch.classList.remove('is-hidden');
      formDiscover.classList.add('is-hidden');
      return typeof scratchFunc === "function" ? scratchFunc() : undefined;
    }
  };

  const changeServiceSource = () => {
    clearNamespaces();
    clearServiceNames();
    return showServiceForm(formSource.source.value, fetchNamespaces);
  };

  const changeClusterNamespace = () => {
    clearServiceNames();
    const selectedNamespace = formDiscover.service_namespace.value
    return selectedNamespace !== '' ? fetchServices(selectedNamespace) : undefined;
  };

  const addOptionToSelect = (selectElem, val) => {
    let opt = document.createElement('option');
    opt.text = val;
    opt.value = val;
    return selectElem.appendChild(opt);
  };

  const isFetchSupported = () => {
    return 'fetch' in window;
  }

  const populateNamespaces = data => {
    const projects = data.projects;
    projects.forEach((project, index, array) => addOptionToSelect(formDiscover.service_namespace, project.metadata.name));
    return projects.length > 0 ? (
      formDiscover.service_namespace.selectedIndex = 1,
      changeClusterNamespace()
    ) : undefined;
  }

  const fetchNamespaces = () => {
    if (isFetchSupported()) {
      fetch('/p/admin/service_discovery/projects.json')
        .then(response => response.json())
        .then(data => populateNamespaces (data));
    } else {
      $.getJSON('/p/admin/service_discovery/projects.json', (data) => {
        populateNamespaces (data)
      });
    }
  }

  const populateServices = data => {
    const services = data.services;
    services.forEach((service, index, array) => addOptionToSelect(formDiscover.service_name, service.metadata.name));
    return services.length > 0 ? formDiscover.service_name.selectedIndex = 1 : undefined;
  }

  const fetchServices = namespace => {
    if (isFetchSupported()) {
      fetch(`/p/admin/service_discovery/namespaces/${namespace}/services.json`)
        .then(response => response.json())
        .then(data => populateServices (data));
    } else{
      $.getJSON(`/p/admin/service_discovery/namespaces/${namespace}/services.json`, (data) => {
        populateServices(data);
      });
    }
  };

  if (formSource !== null) {
    const radioGroup = formSource.source;
    for(let item of radioGroup){
      item.addEventListener('click', changeServiceSource);
    }
  }

  if (formDiscover !== null) {
    formDiscover.service_namespace.addEventListener('change', changeClusterNamespace);
  }

});

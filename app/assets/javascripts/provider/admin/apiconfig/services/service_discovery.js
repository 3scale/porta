document.addEventListener("DOMContentLoaded", function(e) {

  const formSource = document.getElementById('new_service_source');
  const formScratch = document.querySelectorAll('form#new_service, form#create_service')[0];
  const formDiscover = document.getElementById('service_discovery');

  function clearSelectOptions(select) {
    const options = select.getElementsByTagName('option');
    for (var i = options.length -1; i > 0; i--) {
      options[i].remove();
    }
  };

  function clearNamespaces() {
    return clearSelectOptions(formDiscover.service_namespace);
  };

  function clearServiceNames() {
    return clearSelectOptions(formDiscover.service_name);
  };

  function showAndHideForms(showForm, hideForm) {
    showForm.classList.remove('is-hidden');
    hideForm.classList.add('is-hidden');
  }

  function showServiceForm(source, discoverFunc, scratchFunc) {
    if (source === 'discover') {
      showAndHideForms(formDiscover, formScratch);
      return typeof discoverFunc === "function" ? discoverFunc() : undefined;
    } else {
      showAndHideForms(formScratch, formDiscover);
      return typeof scratchFunc === "function" ? scratchFunc() : undefined;
    }
  };

  function changeServiceSource() {
    clearNamespaces();
    clearServiceNames();
    return showServiceForm(formSource.source.value, fetchNamespaces);
  };

  function changeClusterNamespace() {
    clearServiceNames();
    const selectedNamespace = formDiscover.service_namespace.value;
    return selectedNamespace !== '' ? fetchServices(selectedNamespace) : undefined;
  };

  function addOptionToSelect(selectElem, val) {
    var opt = document.createElement('option');
    opt.text = val;
    return selectElem.appendChild(opt);
  };

  function fetchData(url, type) {
    if ('fetch' in window) {
      fetch(url)
      .then(function(response) {
          return response.json();
      })
      .then(function(data){
        populateOptions(type, data);
      });
    } else {
      return $.getJSON(url, function(data) {
        populateOptions(type, data);
      });
    }
  }

  function populateOptions(type, data) {
    switch (type) {
      case 'namespaces':
        populateNamespaces(data);
        break;
      case 'services':
        populateServices(data);
        break;
    }
  }

  function populateNamespaces(data) {
    const projects = data.projects;
    projects.forEach(function(project, index, array){
      addOptionToSelect(formDiscover.service_namespace, project.metadata.name);
    });
    return projects.length > 0 ? (
      formDiscover.service_namespace.selectedIndex = 1,
      changeClusterNamespace()
    ) : undefined;
  }

  function fetchNamespaces() {
    const URLNamespaces = '/p/admin/service_discovery/projects.json';
    fetchData(URLNamespaces, 'namespaces');
  }

  function populateServices(data) {
    const services = data.services;
    services.forEach(function(service, index, array) {
      addOptionToSelect(formDiscover.service_name, service.metadata.name);
    });
    return services.length > 0 ? formDiscover.service_name.selectedIndex = 1 : undefined;
  }

  function fetchServices(namespace) {
    const URLServices = '/p/admin/service_discovery/namespaces/' + namespace + '/services.json';
    fetchData(URLServices, 'services');
  };

  if (formSource !== null) {
    const radioGroup = formSource.source;
    for (var i = 0; i < radioGroup.length; i++) {
      radioGroup[i].addEventListener('click', changeServiceSource);
    }
  }

  if (formDiscover !== null) {
    formDiscover.service_namespace.addEventListener('change', changeClusterNamespace);
  }

});

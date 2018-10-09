document.addEventListener("DOMContentLoaded", function(e) {

  const formSource = document.getElementById('new_service_source');
  const formScratch = document.querySelectorAll('form#new_service, form#create_service')[0];
  const formDiscover = document.getElementById('service_discovery');

  function clearSelectOptions(select) {
    const options = select.getElementsByTagName('option');
    for (let i = options.length -1; i > 0; i--) {
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
    let opt = document.createElement('option');
    opt.text = val;
    opt.value = val;
    return selectElem.appendChild(opt);
  };

  function isFetchSupported() {
    return 'fetch' in window;
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
    if (isFetchSupported()) {
      fetch('/p/admin/service_discovery/projects.json')
        .then(function(response) {
          return response.json();
        })
        .then(function(data){
          return populateNamespaces(data);
        });
    } else {
      $.getJSON('/p/admin/service_discovery/projects.json', function(data) {
        return populateNamespaces(data);
      });
    }
  }

  function populateServices(data) {
    const services = data.services;
    services.forEach(function(service, index, array) {
      addOptionToSelect(formDiscover.service_name, service.metadata.name);
    });
    return services.length > 0 ? formDiscover.service_name.selectedIndex = 1 : undefined;
  }

  function fetchServices(namespace) {
    if (isFetchSupported()) {
      fetch(`/p/admin/service_discovery/namespaces/${namespace}/services.json`)
        .then(function(response) {
          return response.json();
        })
        .then(function(data) {
          return populateServices(data);
        });
    } else{
      $.getJSON(`/p/admin/service_discovery/namespaces/${namespace}/services.json`, function(data) {
        return populateServices(data);
      });
    }
  };

  if (formSource !== null) {
    const radioGroup = formSource.source;
    radioGroup.forEach(function(item) {
      item.addEventListener('click', changeServiceSource);
    });
  }

  if (formDiscover !== null) {
    formDiscover.service_namespace.addEventListener('change', changeClusterNamespace);
  }

});

document.addEventListener("DOMContentLoaded", function(e) {

  const BASE_URL = '/p/admin/service_discovery/';
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

      if (typeof discoverFunc === "function") {
        discoverFunc();
      }
    } else {
      showAndHideForms(formScratch, formDiscover);
      
      if (typeof scratchFunc === "function") {
        scratchFunc();
      }
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
    if (selectedNamespace !== '') {
      fetchServices(selectedNamespace);
    }
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
    if (projects.length > 0) {
      formDiscover.service_namespace.selectedIndex = 1;
      changeClusterNamespace();
    }
  }

  function fetchNamespaces() {
    fetchData(BASE_URL + '/projects.json', 'namespaces');
  }

  function populateServices(data) {
    const services = data.services;
    services.forEach(function(service, index, array) {
      addOptionToSelect(formDiscover.service_name, service.metadata.name);
    });
    if (services.length > 0) {
      formDiscover.service_name.selectedIndex = 1
    }
  }

  function fetchServices(namespace) {
    const URLServices = BASE_URL + '/namespaces/' + namespace + '/services.json';
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

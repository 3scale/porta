document.addEventListener("DOMContentLoaded", (e) => {

  const form_source = document.getElementById('new_service_source');
  const form_scratch = document.querySelectorAll('form#new_service, form#create_service')[0];
  const form_discover = document.getElementById('service_discovery');

  const clear_select_options = select => {
    const options = select.getElementsByTagName('option');
    for (let i = options.length -1; i > 0; i--) {
      options[i].remove()
    }
  };

  const clear_namespaces = () => {
    return clear_select_options(form_discover.service_namespace);
  };

  const clear_service_names = () => {
    return clear_select_options(form_discover.service_name);
  };

  const show_service_form = (source, discover_func, scratch_func) => {
    if (source === 'discover') {
      form_scratch.classList.add('is-hidden');
      form_discover.classList.remove('is-hidden');
      return typeof discover_func === "function" ? discover_func() : undefined;
    } else {
      form_scratch.classList.remove('is-hidden');
      form_discover.classList.add('is-hidden');
      return typeof scratch_func === "function" ? scratch_func() : undefined;
    }
  };

  const change_service_source = () => {
    clear_namespaces();
    clear_service_names();
    return show_service_form(form_source.source.value, fetch_namespaces);
  };

  const change_cluster_namespace = () => {
    clear_service_names();
    const selected_namespace = form_discover.service_namespace.value
    return selected_namespace !== '' ? fetch_services(selected_namespace) : undefined;
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
    projects.forEach((project, index, array) => addOptionToSelect(form_discover.service_namespace, project.metadata.name));
    return projects.length > 0 ? (
      form_discover.service_namespace.selectedIndex = 1,
      change_cluster_namespace()
    ) : undefined;
  }

  const fetch_namespaces = () => {
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
    services.forEach((service, index, array) => addOptionToSelect(form_discover.service_name, service.metadata.name));
    return services.length > 0 ? form_discover.service_name.selectedIndex = 1 : undefined;
  }

  const fetch_services = namespace => {
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

  if (form_source !== null) {
    const radioGroup = form_source.source;
    for(let item of radioGroup){
      item.addEventListener('click', change_service_source);
    }
  }

  if (form_discover !== null) {
    form_discover.service_namespace.addEventListener('change', change_cluster_namespace);
  }

});

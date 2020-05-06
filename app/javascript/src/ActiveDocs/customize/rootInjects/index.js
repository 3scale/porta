const { service } = document.getElementById('swagger-ui-container').dataset
export const RootInjectsPlugin = (system) => {
  return {
    rootInjects: {
      service: JSON.parse(service)
    }
  }
}

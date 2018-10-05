export const applicationDetails = function (data) {
  function details (data, type) {
    return {
      id: data.id,
      name: data.name,
      link: createLink(data, type)
    }
  }

  function createLink (data, type) {
    const id = data.id
    return (type === 'account') ? `/buyers/accounts/${id}` : `/apiconfig/services/${data.service.id}/applications/${id}`
  }

  return {
    account: details(data.application.account, 'account'),
    application: details(data.application, 'application'),
    total: data.total
  }
}

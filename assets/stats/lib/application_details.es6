export const applicationDetails = function (data) {
  function details (data, type) {
    return {
      id: data.id,
      name: data.name,
      link: createLink(data.id, type)
    }
  }

  function createLink (id, type) {
    return (type === 'account') ? `/buyers/accounts/${id}` : `/buyers/applications/${id}`
  }

  return {
    account: details(data.application.account, 'account'),
    application: details(data.application, 'application'),
    total: data.total
  }
}

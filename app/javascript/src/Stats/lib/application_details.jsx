export const applicationDetails = function (data) {
  function details (data) {
    return {
      id: data.id,
      name: data.name,
      link: data.link
    }
  }

  return {
    account: details(data.application.account),
    application: details(data.application),
    total: data.total
  }
}

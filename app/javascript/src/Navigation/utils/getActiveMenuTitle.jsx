export default function getActiveMenuTitle (activeMenu, currentApi) {
  switch (activeMenu) {
    case 'dashboard':
      return 'Dashboard'

    case 'personal':
      return 'Personal Settings'

    case 'account':
      return 'Account'

    case 'buyers':
    case 'finance':
    case 'cms':
    case 'site':
      return 'Audience'

    case 'settings':
      return 'Preferences'

    case 'applications':
    case 'active_docs':
      return 'All APIs'

    case 'serviceadmin':
    case 'monitoring':
      return `API: ${currentApi.service.name}`

    default:
      return 'Choose an API'
  }
}

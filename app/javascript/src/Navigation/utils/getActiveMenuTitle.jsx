export default function getActiveMenuTitle (activeMenu, currentApi) {
  switch (activeMenu) {
    case 'dashboard':
      return 'Dashboard'

    case 'personal':
    case 'account':
      return 'Account Settings'

    case 'audience':
    case 'buyers':
    case 'finance':
    case 'cms':
    case 'site':
    case 'settings':
      return 'Audience'

    case 'apis':
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

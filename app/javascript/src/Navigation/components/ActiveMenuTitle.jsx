import React from 'react'

const ActiveMenuTitle = ({ activeMenu, currentApi }) => {
  switch (activeMenu) {
    case 'dashboard':
      return <React.Fragment><i class="fa fa-home" /> Dashboard </React.Fragment>

    case 'personal':
    case 'account':
      return <React.Fragment><i className="fa fa-cog" /> Account Settings </React.Fragment>

    case 'audience':
    case 'buyers':
    case 'finance':
    case 'cms':
    case 'site':
    case 'settings':
      return <React.Fragment><i class="fa fa-users" /> Audience </React.Fragment>

    case 'apis':
    case 'applications':
    case 'active_docs':
      return <React.Fragment><i className="fa fa-puzzle-piece" /> All APIs </React.Fragment>

    case 'serviceadmin':
    case 'monitoring':
      return <React.Fragment><i className="fa fa-puzzle-piece" /> API: {currentApi.service.name} </React.Fragment>

    default:
      return <React.Fragment><i className="fa fa-puzzle-piece" /> Choose an API </React.Fragment>
  }
}

export { ActiveMenuTitle }

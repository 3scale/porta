// @flow

import * as React from 'react'
import { DocumentationMenuItem } from 'Navigation/components/header'
import { DocsProps } from 'Navigation/components/header/types'

type DocumentationMenuProps = {
  docsLink: DocsProps.docsLink,
  isSaas: DocsProps.isSaas,
  docsLinksClass: DocsProps.isSaas,
  customerPortalLink: DocsProps.isSaas,
  apiDocsLink: DocsProps.isSaas,
  liquidReferenceLink: DocsProps.isSaas,
  whatIsNewLink: DocsProps.isSaas
}

const renderMenuItems = (docsLinksClass, items) => items.map(
  item => <DocumentationMenuItem key={item.text.replace(' ', '')} docsLinksClass={docsLinksClass} item={item}/>
)

const DocumentationMenu = ({docsLink, isSaas, docsLinksClass, customerPortalLink, apiDocsLink, liquidReferenceLink, whatIsNewLink}: DocumentationMenuProps): React.Node => {
  const items = [
    {text: 'Customer Portal', href: customerPortalLink, iconClass: 'fa-external-link', target: '_blank'},
    {text: '3scale API Docs', href: apiDocsLink, iconClass: 'fa-puzzle-piece', target: '_self'},
    {text: 'Liquid Reference', href: liquidReferenceLink, iconClass: 'fa-code', target: '_self'}
  ]
  if (isSaas) {
    items.push({text: `What's new?`, href: whatIsNewLink, iconClass: 'fa-leaf', target: '_blank'})
  }
  return <div className="PopNavigation PopNavigation--docs">
    <a className={`PopNavigation-trigger u-toggler ${docsLink}`} href="#documentation-menu" title="Documentation">
      <i className="fa fa-question-circle "></i>
    </a>
    <ul className="PopNavigation-list u-toggleable" id="documentation-menu">
      { renderMenuItems(docsLinksClass, items) }
    </ul>
  </div>
}

export { DocumentationMenu }

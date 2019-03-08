import React from 'react'
import DocumentationMenuItem from 'Navigation/components/header/DocumentationMenuItem'

const renderMenuItems = (docsLinksClass, items) => items.map(
  (item, index) => <DocumentationMenuItem key={`docsMenuItem${index}`} docsLinksClass={docsLinksClass} item={item}/>
)

const DocumentationMenu = ({docsLink, isSaas, docsLinksClass, customerPortalLink, apiDocsLink, liquidReferenceLink, whatIsNewLink}) => {
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

export default DocumentationMenu

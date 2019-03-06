import React from 'react'

let menuItemKey = 0
const renderItems = (items, docsLinksClass) => items.map(item => <li
  className="PopNavigation-listItem" key={`docsMenuItem${menuItemKey++}`}>
  <a className={docsLinksClass} target={item.target} href={item.href}>
    <i className={`fa ${item.iconClass} fa-fw`}></i> {item.text}
  </a>
</li>)

const DocumentationItemMenu = ({docsLink, isSaas, docsLinksClass, customerPortalLink, apiDocsLink, liquidReferenceLink, whatIsNewLink}) => {
  const items = [
    {text: 'Customer Portal', href: customerPortalLink, iconClass: 'fa-external-link', target: '_blank'},
    {text: '3scale API Docs', href: apiDocsLink, iconClass: 'fa-puzzle-piece', target: '_self'},
    {text: 'Liquid Reference', href: liquidReferenceLink, iconClass: 'fa-code', target: '_self'}
  ]
  if (isSaas) {
    items.push({text: `What's new?`, href: whatIsNewLink, iconClass: 'fa-leaf', target: '_blank'})
  }
  return <div className="PopNavigation PopNavigation--docs">
    <a className={`PopNavigation-trigger u-toggler is-toggled ${docsLink}`} href="#documentation-menu" title="Documentation">
      <i className="fa fa-question-circle "></i>
    </a>
    <ul className="PopNavigation-list u-toggleable" id="documentation-menu">
      { renderItems(items, docsLinksClass) }
    </ul>
  </div>
}
export default DocumentationItemMenu

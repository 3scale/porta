import React from 'react'

const DocumentationMenuItem = ({docsLinksClass, item}) => (
  <li className="PopNavigation-listItem">
    <a className={docsLinksClass} target={item.target} href={item.href}>
      <i className={`fa ${item.iconClass} fa-fw`}></i> {item.text}
    </a>
  </li>
)

export default DocumentationMenuItem

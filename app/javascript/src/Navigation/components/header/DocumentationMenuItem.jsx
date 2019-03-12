// @flow

import * as React from 'react'

type ItemType = {
  target: string,
  href: string,
  iconClass: string,
  text: string
}

const DocumentationMenuItem = ({docsLinksClass, item}: {docsLinksClass: string, item: ItemType}): React.Node => (
  <li className="PopNavigation-listItem">
    <a className={docsLinksClass} target={item.target} href={item.href}>
      <i className={`fa ${item.iconClass} fa-fw`}></i> {item.text}
    </a>
  </li>
)

export { DocumentationMenuItem }

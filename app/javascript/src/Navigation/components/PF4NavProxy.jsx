import React, { useState } from 'react'

import 'Navigation/styles/PF4NavProxy.scss'

const Nav = ({children}) => (
  <nav className="pf-c-nav" aria-label="Global">
    <ul className="pf-c-nav__list">
      {children}
    </ul>
  </nav>
)

const NavExpandable = ({id, title, isExpanded, isActive, children}) => {
  const [expanded, setExpanded] = useState(isExpanded)

  function onItemClick () {
    setExpanded(expanded => !expanded)
  }

  return (
    <li className={`pf-c-nav__item pf-m-expandable ${expanded ? 'pf-m-expanded' : ''} ${isActive ? 'pf-m-current' : ''}`}>
      <a href="#" className="pf-c-nav__link" id={id} aria-expanded="true" onClick={onItemClick}>
        {title}
        <span className="pf-c-nav__toggle">
          <svg style={{ verticalAlign: '-0.125em' }} fill="currentColor" height="1em" width="1em" viewBox="0 0 256 512" aria-hidden="true" role="img">
            <path d="M224.3 273l-136 136c-9.4 9.4-24.6 9.4-33.9 0l-22.6-22.6c-9.4-9.4-9.4-24.6 0-33.9l96.4-96.4-96.4-96.4c-9.4-9.4-9.4-24.6 0-33.9L54.3 103c9.4-9.4 24.6-9.4 33.9 0l136 136c9.5 9.4 9.5 24.6.1 34z" transform=""></path>
          </svg>
        </span>
      </a>
      <section className="pf-c-nav__subnav" aria-labelledby={id}>
        <ul className="pf-c-nav__simple-list">
          {children}
        </ul>
      </section>
    </li>
  )
}

const NavItem = ({to, isActive, children}) => (
  <li className="pf-c-nav__item">
    <a href={to} className={`pf-c-nav__link ${isActive ? 'pf-m-current' : ''}`} aria-current="page">
      {children}
    </a>
  </li>
)

const NavList = ({children}) => (
  <ul className="pf-c-nav__list">
    {children}
  </ul>
)

const NavGroup = ({title}) => (
  <h2 className="pf-c-nav__section-title">
    {title}
  </h2>
)

export { Nav, NavExpandable, NavItem, NavList, NavGroup }

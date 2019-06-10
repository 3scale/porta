import React from 'react'

const Nav = ({children}) => (
  <nav className="pf-c-nav" aria-label="Global">
    <ul className="pf-c-nav__list">
      {children}
    </ul>
  </nav>
)

const NavExpandable = ({id, title, isExpanded, isActive, children}) => (
  <li className={`pf-c-nav__item pf-m-expandable ${isExpanded ? 'pf-m-expanded' : ''} ${isActive ? 'pf-m-current' : ''}`}>
    <a href="#" className="pf-c-nav__link" id={id} aria-expanded="true">
      {title}
      <span className="pf-c-nav__toggle">
        <i className="fas fa-angle-right" aria-hidden="true"></i>
      </span>
    </a>
    <section className="pf-c-nav__subnav" aria-labelledby={id}>
      <ul className="pf-c-nav__simple-list">
        {children}
      </ul>
    </section>
  </li>
)

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

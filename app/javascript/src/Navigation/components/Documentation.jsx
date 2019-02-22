import React from 'react'

const renderWhatsNew = (docsLinksClass, whatIsNewLink) => <li className="PopNavigation-listItem">
  <a className={docsLinksClass} target="_blank" href={whatIsNewLink}>
    <i className="fa fa-leaf fa-fw"></i> What's new?
  </a>
</li>

const DocumentationItemMenu = ({docsLink, isSaas, docsLinksClass, customerPortalLink, apiDocsLink, liquidReferenceLink, whatIsNewLink}) => <div className="PopNavigation PopNavigation--docs">
  <a className={`PopNavigation-trigger u-toggler is-toggled ${docsLink}`} href="#documentation-menu" title="Documentation">
    <i className="fa fa-question-circle "></i>
  </a>
  <ul className="PopNavigation-list u-toggleable" id="documentation-menu">
    <li className="PopNavigation-listItem">
      <a className={docsLinksClass} target="_blank" href={customerPortalLink}>
        <i className="fa fa-external-link fa-fw"></i> Customer Portal
      </a>
    </li>
    <li className="PopNavigation-listItem">
      <a className={docsLinksClass} href={apiDocsLink}>
        <i className="fa fa-puzzle-piece fa-fw"></i> 3scale API Docs
      </a>
    </li>
    <li className="PopNavigation-listItem">
      <a className={docsLinksClass} href={liquidReferenceLink}>
        <i className="fa fa-code fa-fw"></i> Liquid Reference
      </a>
    </li>
    { isSaas ? renderWhatsNew(docsLinksClass, whatIsNewLink) : null }
  </ul>
</div>

export default DocumentationItemMenu

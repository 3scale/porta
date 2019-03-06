import React from 'react'
import ContextSwitcher from 'Navigation/components/ContextSwitcherContainer'

const Brand = () => <div className="u-header-brand">
  <div className="u-header-left-half">
    <div className='Header-logo'>Red Hat 3scale API Management</div>
  </div>
  <div className="u-header-right-half">
    <ContextSwitcher/>
  </div>
</div>

export default Brand

import {
  ParameterRow as parameterRow
} from 'ActiveDocs/customize/wrappedComponents/Parameters'

export const WrappedComponentsPlugin = (system) => {
  return {
    afterLoad (system) {
      this.rootInjects.service = this.rootInjects.service.service || {}
    },
    wrapComponents: {
      parameterRow
    }
  }
}

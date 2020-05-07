import {
  CustomParameterRow as parameterRow
} from 'ActiveDocs/customize/wrappedComponents/Parameters'

export const WrappedComponentsPlugin = (system) => {
  return {
    afterLoad (system) {
      this.rootInjects.customParamsList = this.rootInjects.customParamsList || {}
    },
    wrapComponents: {
      parameterRow
    }
  }
}

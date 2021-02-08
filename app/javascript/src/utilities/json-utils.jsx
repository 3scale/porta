// @flow

// eslint-disable-next-line flowtype/no-weak-types
const toJsonString = (val: Object): string => JSON.stringify(val, null, 2)

const fromJsonString = (json: string) => JSON.parse(json)

const safeFromJsonString = <T>(json: string | void): (T | void) => {
  if (json === undefined) return undefined

  try {
    return fromJsonString(json)
  } catch (err) {
    console.warn('That doesn\'t look like a valid json!', err)
    return undefined
  }
}

export {
  toJsonString,
  fromJsonString,
  safeFromJsonString
}

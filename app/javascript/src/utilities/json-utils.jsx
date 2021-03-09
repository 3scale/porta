// @flow

// eslint-disable-next-line flowtype/no-weak-types
const toJsonString = (val: Object): string => JSON.stringify(val, null, 2)

const fromJsonString = <T>(json: string): T => JSON.parse(json)

const safeFromJsonString = <T>(json: string | void): (T | void) => {
  if (json === undefined) {
    // Explicitly return undefined to prevent JSON.parse from throwing an error
    return undefined
  }

  try {
    return fromJsonString<T>(json)
  } catch (err) {
    console.error('That doesn\'t look like a valid json!', err)
    return undefined
  }
}

export {
  toJsonString,
  fromJsonString,
  safeFromJsonString
}

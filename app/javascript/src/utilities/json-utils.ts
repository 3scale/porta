const toJsonString = (val: unknown): string => JSON.stringify(val, null, 2)

const fromJsonString = <T>(json: string): T => JSON.parse(json) as T

const safeFromJsonString = <T>(json?: string): T | undefined => {
  if (json === undefined) {
    // Explicitly return undefined to prevent JSON.parse from throwing an error
    return undefined
  }

  try {
    return fromJsonString<T>(json)
  } catch (err: unknown) {
    console.error('That doesn\'t look like a valid json!', err)
    return undefined
  }
}

export {
  toJsonString,
  fromJsonString,
  safeFromJsonString
}

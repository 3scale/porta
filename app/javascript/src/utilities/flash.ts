const { flash } = window.$

export const notice = (msg: string): void => { flash.notice(msg) }
export const error = (msg: string): void => { flash.error(msg) }

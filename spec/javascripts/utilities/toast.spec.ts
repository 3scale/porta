// eslint-disable-next-line @typescript-eslint/consistent-type-imports
const toastLib = jest.requireActual<typeof import('utilities/toast')>('utilities/toast')

const { toast, hideToastDelayed } = toastLib

afterEach(() => {
  jest.restoreAllMocks()
})

describe('#toast', () => {
  it('should throw an error if there is no alert group', () => {
    expect(() => { toast('Hi Pepe!') }).toThrow()
  })

  it('should add an alert and schedule it for removal', () => {
    const hideToastDelayed = jest.spyOn(toastLib, 'hideToastDelayed')
    document.body.innerHTML = `
      <div>
        <ul class="pf-c-alert-group pf-m-toast"></ul>
      <div
    `

    expect(document.querySelector('ul')!.children.length).toEqual(0)
    toast('Hi Pepe!')

    expect(document.querySelector('ul .pf-c-alert p')!.textContent).toEqual('default alert: Hi Pepe!')
    expect(hideToastDelayed).toHaveBeenCalledTimes(1)
  })
})

describe('#hideToastDelayed', () => {
  it('should hide a toast after 5 seconds', () => {
    jest.useFakeTimers()
    jest.spyOn(global, 'setTimeout')
    jest.spyOn(toastLib, 'hideToast').mockImplementation(toast => { toast.remove() })

    document.body.innerHTML = `
      <div>
        <ul class="pf-c-alert-group pf-m-toast">
          <li class="pf-c-alert"></li>
        </ul>
      <div
    `

    hideToastDelayed(document.querySelector('.pf-c-alert')!)
    expect(setTimeout).toHaveBeenLastCalledWith(expect.any(Function), 8000)

    jest.runAllTimers()
    expect(document.querySelector('.pf-c-alert')).toBeNull()
  })
})

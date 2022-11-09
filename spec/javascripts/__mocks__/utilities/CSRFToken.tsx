module.exports = {
  CSRFToken: () => (
    <input
      name="mocked-csrf-param"
      type="hidden"
      value="mocked-csrf-token"
    />
  )
}

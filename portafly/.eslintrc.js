module.exports = {
  root: true,
  plugins: [
    'jest'
  ],
  extends: [
    'airbnb-typescript',
    'plugin:jest/recommended'
  ],
  parserOptions: {
    project: './tsconfig.json',
  },
  rules: {
    'semi': ['error', 'never'],
    'comma-dangle': ['error', 'never'],
    'no-prototype-builtins': 1,

    // import
    'import/no-extraneous-dependencies': 1, // Because of @testing-library
    'import/no-default-export': 2,
    'import/prefer-default-export': 0,
    'import/no-unresolved': 0, // Need to add a resolver probably https://github.com/benmosher/eslint-plugin-import/blob/master/README.md#resolvers

    // typescript
    '@typescript-eslint/semi': 0,

    // react
    'react/prop-types': 0,
  }
}

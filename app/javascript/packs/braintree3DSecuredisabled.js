var $form = $('#customer_form')
var submit = document.querySelector('input[type="submit"]')
var braintree = window.braintree
var braintreeAuthorization = $form.attr('data-client-token')

if (typeof braintree !== 'undefined') {
  braintree.client.create({
    authorization: braintreeAuthorization
  }, function (clientErr, clientInstance) {
    if (clientErr) {
      console.error(clientErr)
      return
    }

    // This example shows Hosted Fields, but you can also use this
    // client instance to create additional components here, such as:qa
    // PayPal or Data Collector.

    braintree.hostedFields.create({
      client: clientInstance,
      styles: {
        'input': {
          'font-size': '14px'
        },
        'input.invalid': {
          'color': 'red'
        },
        'input.valid': {
          'color': 'green'
        }
      },
      fields: {
        number: {
          selector: '#customer_credit_card_number',
          placeholder: '4111 1111 1111 1111'
        },
        cvv: {
          selector: '#customer_credit_card_cvv',
          placeholder: '123'
        },
        expirationDate: {
          selector: '#customer_credit_card_expiration_date',
          placeholder: 'MM/YY'
        }
      }
    }, function (hostedFieldsErr, hostedFieldsInstance) {
      if (hostedFieldsErr) {
        console.error(hostedFieldsErr)
        return
      }

      submit.removeAttribute('disabled')

      $form.on('submit', function (event) {
        event.preventDefault()
        hostedFieldsInstance.tokenize(function (tokenizeErr, payload) {
          if (tokenizeErr) {
            console.error(tokenizeErr)
            return
          }
          $('#braintree_nonce').val(payload['nonce'])
          $form.get(0).submit()
        })
      })
    })
  })
}

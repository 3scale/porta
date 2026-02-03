# Stripe Rate Limit (429) Error Handling

## Overview

This document describes how the billing system handles Stripe API rate limit errors (HTTP 429).

## Problem

Stripe API has a default rate limit of 25 requests per second. When exceeded, Stripe returns a 429 error. Previously, these errors were treated the same as payment failures (declined cards), causing:

- **Long retry delays**: Invoices wouldn't be retried for 3 days
- **Invoice state pollution**: Invoices marked as "unpaid" when they should just retry
- **Poor user experience**: Temporary API issues treated as payment failures
- **Buyer notifications**: Unnecessary "unsuccessful charge" emails

## Solution: Job-Level Retry with Exponential Backoff

Rate limit errors bubble up to the Sidekiq worker level and trigger immediate retry with exponential backoff.

### Why This Approach is Safe

**Key insight**: Invoice state is committed immediately when `pay!` is called.

1. ✅ **No transactions**: No transaction wrapper around billing jobs
2. ✅ **Immediate save**: State machine calls `save!` immediately on transition
3. ✅ **`chargeable` scope protects**: Paid invoices excluded from retry processing
4. ✅ **Tests prove it**: Existing tests show state persists through errors

**Flow Example:**
```
Job starts → Process invoices
  Invoice #1: charge! → pay! → save! (COMMITTED to DB as "paid")
  Invoice #2: charge! → RateLimitError raised
Job fails and retries in 15 seconds

Retry queries database:
  Invoice #1: state="paid" → excluded by chargeable scope ✓
  Invoice #2: state="pending" → included, retried ✓
```

## Implementation Details

### 1. Rate Limit Detection (payment_transaction.rb:121-133)

```ruby
def rate_limit_error?(response)
  return false unless response

  # Check HTTP 429 status
  http_code = response.params.dig('error', 'http_code')
  return true if http_code == 429 || http_code == '429'

  # Check error message patterns
  message = response.message.to_s.downcase
  message.include?('rate limit') || message.include?('too many requests') || message.include?('429')
end
```

### 2. Exception Raising (payment_transaction.rb:35-42)

```ruby
def process!(credit_card_auth_code, gateway, options)
  # ... process payment ...

  if rate_limit_error?(response)
    Rails.logger.warn("Rate limit detected (429)")
    raise Finance::Payment::RateLimitError.new(response)
  end
end
```

### 3. Invoice Re-raising (invoice.rb:454-458)

```ruby
def charge!(automatic = true)
  # ... charge logic ...
rescue Finance::Payment::RateLimitError => e
  # Re-raise to bubble up to BillingWorker
  logger.warn("Rate limit error for invoice #{id} - will retry via Sidekiq")
  raise e
rescue Finance::Payment::CreditCardError, ActiveMerchant::ActiveMerchantError
  # Regular payment errors handled differently
  self.charging_retries_count += 1
  mark_as_unpaid!
  # ...
end
```

### 4. Lock Release (billing_service.rb:29-42)

```ruby
def call!
  acquire_lock
  call
rescue Finance::Payment::RateLimitError => error
  # Release lock so retry can proceed immediately
  release_lock
  report_error(error)
  raise error  # Re-raise for Sidekiq
rescue LockBillingError, SpuriousBillingError => error
  report_error(error)
  nil
end
```

### 5. Exponential Backoff (billing_worker.rb:8-18)

```ruby
sidekiq_options queue: :billing, retry: 5

sidekiq_retry_in do |count, exception|
  case exception
  when Finance::Payment::RateLimitError
    # Exponential backoff: ~15s, ~45s, ~135s, ~405s, ~1215s
    delay = (3 ** count) * 5
    jitter = rand(0..5)  # Prevent thundering herd
    delay + jitter
  else
    1.hours + 10  # Standard retry for other errors
  end
end
```

## Behavior

### When Rate Limit Occurs

**Timeline:**
```
10:00:00 - Job starts billing buyer #123
10:00:03 - Invoice #1 ($100) charged successfully → "paid" (COMMITTED)
10:00:05 - Invoice #2 ($200) hits rate limit → RateLimitError raised
         - Job fails
         - Lock released
         - Sidekiq schedules retry for 10:00:20 (15s + jitter)

10:00:20 - Job retries
         - Queries chargeable invoices:
           - Invoice #1: "paid" → NOT IN SCOPE ✓
           - Invoice #2: "pending" → IN SCOPE ✓
         - Only charges Invoice #2
         - Success!
```

### Comparison

| Aspect | Rate Limit Error | Regular Payment Error |
|--------|-----------------|---------------------|
| Invoice state | Remains "pending" | Marked "unpaid" |
| Retry counter | NOT incremented | Incremented (1/3) |
| Job behavior | Fails & retries | Completes normally |
| Retry timing | 15s, 45s, 135s... | 3 days later |
| User notification | None | "Unsuccessful charge" email |
| Lock | Released immediately | Held for 1 hour |
| Sidekiq retries | 5 attempts | 3 attempts |

## Retry Schedule

For rate limit errors:
- **Attempt 1**: Immediate (original job)
- **Attempt 2**: ~15-20 seconds later (3^1 * 5 + jitter)
- **Attempt 3**: ~45-50 seconds after attempt 2 (3^2 * 5 + jitter)
- **Attempt 4**: ~135-140 seconds after attempt 3 (3^3 * 5 + jitter)
- **Attempt 5**: ~405-410 seconds after attempt 4 (3^4 * 5 + jitter)
- **Attempt 6**: ~1215-1220 seconds after attempt 5 (3^5 * 5 + jitter)

**Total time**: ~35 minutes for all retries

After 5 failed retries, the job permanently fails and is reported to error tracking.

## Why Lock Release is Safe

**The 1-hour lock protects against running the entire billing workflow twice**, including:
- Creating duplicate line items
- Sending duplicate notifications
- Generating duplicate PDFs

**However**, when we hit a rate limit:
1. Line items already created ✓ (not idempotent)
2. Invoices already finalized ✓ (not idempotent)
3. Invoices already issued ✓ (not idempotent)
4. **Only charging remains** (IS idempotent via `chargeable` scope)

Releasing the lock for rate limits is safe because:
- ✅ All non-idempotent operations already completed
- ✅ `charge_invoices` only processes `chargeable` invoices
- ✅ `chargeable` scope excludes already-paid invoices
- ✅ Worst case: concurrent job tries to run, finds no chargeable invoices

## Edge Cases Handled

1. **Multiple invoices, one hits rate limit**:
   - Already-charged invoices excluded from retry ✓
   - Only rate-limited invoice retried ✓

2. **Concurrent manual trigger during retry**:
   - If lock available: runs, finds no chargeable invoices ✓
   - If lock held: fails gracefully with LockBillingError ✓

3. **Persistent rate limits**:
   - After 5 retries (~35 min), job fails permanently
   - Error reported to monitoring
   - Invoice remains "pending" for next daily cycle

4. **Mixed errors** (rate limit + card decline):
   - First invoice: charges successfully → "paid"
   - Second invoice: rate limit → job fails & retries
   - Retry: only second invoice processed
   - If then succeeds → "paid"
   - If then card declines → "unpaid" with retry counter

## Monitoring

### What to Monitor

1. **Rate limit frequency**: `Finance::Payment::RateLimitError` count
2. **Retry success rate**: How many succeed vs. fail after 5 attempts
3. **Affected buyers**: Track which buyers encounter rate limits

### Alert Thresholds

- **Warning**: >10 rate limit errors/day
- **Critical**: >50 rate limit errors/day (need client-side throttling)

### Log Messages

```
[billing] provider 123 buyer 456: trying to charge invoice 789
Rate limit detected (429) for PaymentTransaction
Rate limit error for invoice 789 (buyer 456) - will retry via Sidekiq: Rate limit exceeded
```

## When to Add Client-Side Rate Limiting

If you see frequent rate limits (>50/day), consider:

1. **Reduce batch size**: Lower `batch_size` in invoice processing
2. **Add delays**: `sleep 0.1` between invoice charges
3. **Spread processing**: Distribute billing across multiple time windows
4. **Request throttling**: Token bucket algorithm at application level

## Files Modified

1. `app/lib/finance/payment.rb` - Added `RateLimitError` exception
2. `app/models/payment_transaction.rb` - Detects 429 errors and raises `RateLimitError`
3. `app/models/invoice.rb` - Re-raises `RateLimitError` (doesn't catch it)
4. `app/services/finance/billing_service.rb` - Releases lock on rate limit, re-raises error
5. `app/workers/billing_worker.rb` - Exponential backoff for rate limits (retry: 5)

## Testing

See `test/integration/finance/stripe_rate_limit_handling_test.rb` for comprehensive coverage.

**Key test**: `test_successful_charge_followed_by_rate_limit_does_not_double_charge_on_retry`

Proves that:
- Invoice #1 charged successfully → "paid"
- Invoice #2 hits rate limit → job fails
- Retry processes only Invoice #2 (Invoice #1 excluded by `chargeable` scope)
- No double charging ✓

## Configuration

No configuration needed. Behavior is automatic based on error detection.

## References

- [Stripe Rate Limit Documentation](https://docs.stripe.com/rate-limits)
- [Stripe Error Handling Best Practices](https://docs.stripe.com/error-handling)
- Stripe API default limit: 25 requests/second

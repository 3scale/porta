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

### 3. Invoice Error Handling (invoice.rb:454-458)

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

### 4. Critical Fix: Prevent Exception Swallowing (billing_strategy.rb:378-383)

**IMPORTANT**: The `bill_and_charge_each` method has a catch-all exception handler that would normally swallow ALL exceptions in production. We must explicitly re-raise `RateLimitError`:

```ruby
buyer_accounts.find_each(:batch_size => 20) do |buyer|
  begin
    ignoring_find_each_scope { yield(buyer) }
  rescue Finance::Payment::RateLimitError => exception
    # CRITICAL: Re-raise immediately - do NOT swallow!
    # This exception needs to bubble up to trigger Sidekiq retry
    raise exception
  rescue => exception
    # All other exceptions are logged and swallowed (production)
    # This is the original behavior for normal billing errors
    error(msg, buyer)
    System::ErrorReporting.report_error(exception, ...)
    @failed_buyers << buyer_id
    raise if Rails.env.test?  # Only re-raise in test env
  end
end
```

**Without this fix**: Rate limit errors would be caught by the catch-all `rescue =>`, logged, and swallowed in production. The job would complete "successfully" and Sidekiq would never retry!

### 5. Better Error Logging (billing_strategy.rb:92-112)

**IMPORTANT**: The class method `Finance::BillingStrategy.daily` has a catch-all exception handler that would log "BillingStrategy N failed utterly" for ANY error. This is misleading for rate limits (which are temporary), so we add a specific rescue:

```ruby
rescue Finance::Payment::RateLimitError => e
  # Rate limit hit - log clearly and re-raise for Sidekiq retry
  # DON'T call results.failure() - this is a transient error, not a failure
  # The job will retry and (likely) succeed
  buyer_ids = options[:buyer_ids]

  # Note: We don't know which specific buyer hit the rate limit,
  # only which buyers were being processed in this job
  buyer_context = if buyer_ids.present?
                    "while processing #{buyer_ids.size} buyer(s): [#{buyer_ids.join(', ')}]"
                  else
                    "while processing all buyers"
                  end

  message = "BillingStrategy #{id}(#{name}) hit rate limit #{buyer_context} - will retry with exponential backoff"

  Rails.logger.warn(message)  # WARN not ERROR
  System::ErrorReporting.report_error(e,
    error_message: message,
    error_class: 'RateLimitError',
    parameters: { billing_strategy_id: id, buyer_ids: buyer_ids })

  raise e  # Re-raise for Sidekiq retry (method exits here, results object discarded)
rescue => e
  # All other errors get "failed utterly" message
  results.failure(billing_strategy)  # Mark as failed in results
  message = "BillingStrategy #{id}(#{name}) failed utterly"
  Rails.logger.error(message)
  raise e
end
```

**Why NOT calling `results.failure()` for rate limits matters**:
- **Semantically correct**: Rate limits are transient, not failures
- **Job will retry**: The Sidekiq retry will likely succeed on the next attempt
- **Results object unused**: Since we `raise e`, the method exits immediately and `results` is never returned/logged anyway
- **Contrast with real failures**: Payment declines, missing data, etc. ARE failures and should be marked as such

**Other improvements**:
- Makes it clear it's a temporary rate limit, not a catastrophic failure
- Honestly logs which buyers were being processed (not claiming to know which specific one failed)
- Uses WARN level instead of ERROR level (rate limits are warnings, not errors)
- Reports as 'RateLimitError' class instead of generic 'BillingError'
- Includes buyer_ids in error reporting parameters for debugging

### 6. Exponential Backoff (billing_worker.rb:8-18)

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

**Timeline (buyer with 3 invoices):**
```
10:00:00 - Job starts billing buyer #123
10:00:03 - Invoice #1 ($100) charged successfully → "paid" (COMMITTED)
10:00:05 - Invoice #2 ($200) hits rate limit → RateLimitError raised
         - Loop exits immediately (Invoice #3 not attempted)
         - Job fails
         - Lock released
         - Sidekiq schedules retry for 10:00:20 (15s + jitter)

10:00:20 - Job retries
         - Queries chargeable invoices:
           - Invoice #1: "paid" → NOT IN SCOPE ✓
           - Invoice #2: "pending" → IN SCOPE ✓
           - Invoice #3: "pending" → IN SCOPE ✓
         - Charges Invoice #2 → Success
         - Charges Invoice #3 → Success
         - All 3 invoices now paid ✓
```

**Why not continue processing after rate limit?**

Rate limits signal that we've exceeded the API threshold. If Invoice #2 hits a rate limit, attempting Invoice #3 will likely also hit a rate limit, contributing to the problem. It's better to:
1. Immediately back off (stop processing)
2. Wait for exponential backoff delay
3. Retry all pending invoices after the delay

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

## Architecture: Jobs and Batches

**Important**: Understanding the job/batch structure is critical:

### Job Granularity

Each `BillingWorker` job processes:
- **Exactly ONE provider**
- **Exactly ONE buyer**

From `billing_service.rb:69-70`:
```ruby
options = { only: [provider_account_id], buyer_ids: [account_id] }
```

### Batch Structure

When `BillingWorker.enqueue(provider, billing_date)` is called:
1. Creates ONE Sidekiq::Batch for the provider
2. Enqueues ONE job PER buyer (e.g., 100 jobs for 100 buyers)
3. Each job is independent and processes its buyer's invoices

**Example: Provider with 100 buyers**
```
Batch #ABC123 (Provider #456)
├── Job #1: Buyer #1 (Provider #456)   → Succeeds
├── Job #2: Buyer #2 (Provider #456)   → Succeeds
├── ...
├── Job #50: Buyer #50 (Provider #456) → Rate limit! Retries...
├── ...
└── Job #100: Buyer #100 (Provider #456) → Succeeds
```

### Batch Completion Behavior

**Critical detail**: The batch waits for ALL jobs (including retries) before completing:

1. **Jobs #1-49**: Complete successfully in ~30 seconds
2. **Job #50**: Hits rate limit
   - Retry #1: ~15s later
   - Retry #2: ~45s later
   - Retry #3: ~135s later
   - Retry #4: ~405s later
   - Retry #5: ~1215s later
   - **Total retry time**: ~35 minutes
3. **Jobs #51-100**: Complete successfully in ~30 seconds
4. **Batch completion**: Waits until Job #50 finishes all retries (~35 minutes)
5. **Callback fires**: `BillingWorker::Callback#on_complete` runs with batch status

### Impact of Rate Limits on Batches

**Good news**:
- ✅ Other buyers ARE billed successfully (jobs complete independently)
- ✅ Their invoices ARE charged correctly
- ✅ Their emails ARE sent
- ✅ Job #50's retries don't affect other jobs' execution

**Trade-off**:
- ⏱️ Batch-level notification is **delayed** until Job #50 completes all retries
- ⏱️ Provider won't receive "billing complete" notification for ~35 minutes
- ⏱️ If multiple buyers hit rate limits, delays compound

**Why this is acceptable**:
- Billing IS happening correctly for all buyers
- Only the batch-level summary notification is delayed
- Rate limits are rare (should be <1% of jobs)
- Alternative (fail entire batch) would be worse

### When This Becomes a Problem

If you see **frequent rate limits** (>5% of jobs):
1. Many jobs retry simultaneously
2. Batch completion significantly delayed
3. May hit rate limits again during retry (thundering herd)

**Solution**: Implement client-side rate limiting (see "When to Add Client-Side Rate Limiting" section)

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

**When rate limit occurs (single buyer job):**
```
# Invoice level
[billing] provider 123 buyer 456: trying to charge invoice 789
Rate limit detected (429) for PaymentTransaction
Rate limit error for invoice 789 - will retry via Sidekiq

# BillingStrategy level (class method)
BillingStrategy 123(ProviderCorp) hit rate limit while processing 1 buyer(s): [456] - will retry with exponential backoff

# BillingService level
Failed to perform billing job: Rate limit exceeded
```

**When rate limit occurs (hypothetical multi-buyer job):**
```
# BillingStrategy level
BillingStrategy 123(ProviderCorp) hit rate limit while processing 3 buyer(s): [456, 457, 458] - will retry with exponential backoff
```

**Note**: In production, each BillingWorker job processes exactly one buyer, so you'll typically see the single-buyer format. The multi-buyer format is shown for completeness in case `bill_and_charge_each` is called from other contexts (e.g., manual billing triggers or rake tasks).

**Contrast with regular payment errors:**
```
# Invoice level
[billing] provider 123 buyer 456: trying to charge invoice 789
Error when charging invoice 789

# BillingStrategy level
BillingStrategy 123(ProviderCorp) failed utterly  ← Only for non-rate-limit errors
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
4. **`app/models/finance/billing_strategy.rb`** - **CRITICAL**: TWO fixes:
   - Line 355-359: Separate rescue in `bill_and_charge_each` to re-raise (not swallow) `RateLimitError`
   - Line 92-106: Separate rescue in `self.daily` for better error logging (warn vs. error)
5. `app/services/finance/billing_service.rb` - Releases lock on rate limit, re-raises error
6. `app/workers/billing_worker.rb` - Exponential backoff for rate limits (retry: 5)

## Testing

See `test/integration/finance/stripe_rate_limit_handling_test.rb` for comprehensive coverage.

**Key test**: `test_successful_charge_followed_by_rate_limit_does_not_double_charge_on_retry`

Proves that:
- Invoice #1 charged successfully → "paid"
- Invoice #2 hits rate limit → job fails (Invoice #3 not attempted)
- Retry processes invoices #2 and #3 (Invoice #1 excluded by `chargeable` scope)
- No double charging ✓

**Test coverage**: 13 tests, 57 assertions, 0 failures ✅

## Configuration

No configuration needed. Behavior is automatic based on error detection.

## References

- [Stripe Rate Limit Documentation](https://docs.stripe.com/rate-limits)
- [Stripe Error Handling Best Practices](https://docs.stripe.com/error-handling)
- Stripe API default limit: 25 requests/second

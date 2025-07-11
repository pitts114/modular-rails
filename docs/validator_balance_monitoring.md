# Validator Balance Monitoring

This document describes the validator balance monitoring system implemented to track AIUS token deposits against the Engine contract's minimum requirements.

## Overview

The system monitors both validators and miners' AIUS token deposits and alerts when deposits fall below 105% of the minimum required amount set by the Engine contract.

## Components

### Engine Contract Methods

New methods added to `Ethereum::Public::EngineContract`:

- `get_validator_minimum()` - Retrieves the minimum validator deposit amount from the contract
- `get_validator_deposit(address:)` - Retrieves the current deposit amount for a specific validator address

### Service

`Arbius::ValidatorBalanceCheckService` - The main service that:
- Fetches the current validator minimum from the Engine contract
- Calculates the 105% threshold
- Checks all validators and miners in the database
- Reports low balances to Sentry

### Job

`Arbius::ValidatorBalanceCheckJob` - A simple job wrapper that calls the service

### Scheduling

The job is scheduled to run every hour via Clockwork (`config/clockwork.rb`).

## Configuration

The threshold percentage is set to 105% (1.05) and can be modified in the service constant:

```ruby
MINIMUM_PERCENTAGE_THRESHOLD = 1.05 # 105% of minimum
```

## Error Handling

The system includes comprehensive error handling:
- Validates that the validator minimum is not nil or zero
- Handles individual address check failures without stopping the entire process
- Reports all errors to Sentry with appropriate context

## Testing

Comprehensive RSpec tests are provided covering:
- Normal operation scenarios
- Edge cases (nil values, errors)
- Sentry reporting verification
- Dependency injection patterns

## Manual Usage

To run the balance check manually:

```ruby
# In Rails console
Arbius::ValidatorBalanceCheckService.new.call

# Or via the job
Arbius::ValidatorBalanceCheckJob.perform_now
```

## Monitoring

Alerts are sent to Sentry when:
- Validator deposits fall below threshold
- Miner deposits fall below threshold
- Contract calls fail
- Individual address checks fail

Each alert includes relevant context such as addresses, deposit amounts, and thresholds.

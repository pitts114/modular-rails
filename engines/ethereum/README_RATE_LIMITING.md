# Ethereum Rate Limiting Configuration

The Ethereum client provider now includes rate limiting to prevent hitting Infura's rate limits. This is completely transparent to existing code.

**See implementation:** [`engines/ethereum/app/services/ethereum/rate_limited_client_wrapper.rb`](app/services/ethereum/rate_limited_client_wrapper.rb#L15)

## Configuration

The rate limiting can be configured via environment variables:

### Basic Rate Limiting (Default)
- `ETHEREUM_RATE_LIMIT`: Number of requests per second (default: 3.0)

### Credit-Based Rate Limiting (Optional)
- `ETHEREUM_USE_CREDIT_LIMITING`: Set to 'true' to enable credit-based limiting
- `ETHEREUM_CREDIT_LIMIT`: Credits per second limit (default: 500)

## How it works

### Basic Rate Limiting
Limits the number of calls per second regardless of the method being called.

### Credit-Based Rate Limiting
Each RPC method has a different "cost" in credits based on Infura's pricing.

## Examples

```bash
# Basic rate limiting (3 calls per second)
ETHEREUM_RATE_LIMIT=3.0

# Credit-based limiting (500 credits per second, for Infura free tier)
ETHEREUM_USE_CREDIT_LIMITING=true
ETHEREUM_CREDIT_LIMIT=500

# Higher rate for paid plans
ETHEREUM_RATE_LIMIT=10.0
```

The rate limiting uses Redis for coordination across multiple processes and is completely transparent to existing application code.

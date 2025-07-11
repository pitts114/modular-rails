# README

This README would normally document whatever steps are necessary to get the
application up and running.

## Engine Tests

To run all engine specs:

```
bundle exec rake engine_specs
```

## Ethereum Integration Tests

To run the Ethereum integration tests, set the environment variable and run the specs:

```
RUN_ETHEREUM_INTEGRATION=true bundle exec rake engine_specs
```

## Event Listener

To start the event listener:

```
bundle exec rake arbius:event_listener
```

## Resque Worker (Background Jobs)

To start a Resque worker that processes background jobs:

```
bundle exec rake resque:work QUEUE='*'
```

- This will process jobs from all queues.
- Make sure Redis is running (see `docker-compose.yml`).
- You can enqueue jobs using ActiveJob (e.g., `HelloJob.perform_later("World")`).

To monitor jobs, start your Rails server and visit `/resque` in your browser (development/test only):

```
bin/rails server
# Then visit http://localhost:3000/resque
```

## Clockwork (Scheduled Jobs)

To start the Clockwork scheduler for running scheduled jobs:

```
bundle exec clockwork config/clockwork.rb
```

- This will run scheduled jobs as defined in `config/clockwork.rb`.
- Make sure any required services (e.g., Redis, database) are running.

## Ethereum Rate Limiting

The application includes a transparent rate-limiting wrapper around `Eth::Client` to prevent hitting Infura rate limits. The wrapper works seamlessly with existing code - no changes are required to use it.

### Configuration

Rate limiting is configured via environment variables:

#### Basic Rate Limiting (Default)
```bash
# Limit to 3 calls per second (default)
ETHEREUM_RATE_LIMIT=3.0
```

#### Credit-Based Limiting (for Infura Free Tier)
```bash
# Enable credit-based limiting
ETHEREUM_USE_CREDIT_LIMITING=true

# Set credit limit (default: 500 for Infura free tier)
ETHEREUM_CREDIT_LIMIT=500
```

### How It Works

- **Transparent**: All existing `Eth::Client` methods work exactly as before
- **Cross-process coordination**: Uses Redis to share rate limits across multiple processes
- **Sliding window**: Smooth rate limiting with automatic retry logic
- **Method-specific costs**: In credit mode, different RPC methods have different costs based on [Infura's pricing](https://docs.metamask.io/services/get-started/pricing/credit-cost/)

### Example Usage

```ruby
# This code works exactly the same as before - rate limiting is automatic
client = Ethereum::ClientProvider.client
client.eth_block_number  # Rate limited automatically
client.get_balance(addr) # All methods forwarded transparently
```

All existing services (`EthContractCallService`, `EthTransferService`, `EventPoller`, etc.) continue working without modification.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

# Helpful Links
Engine - https://arbiscan.io/address/0x9b51ef044d3486a1fb0a2d55a6e0ceeadd323e66
BulkTasks - https://arbiscan.io/address/0x245e065e8c3e45baeb0f087ee4d52fafc2b55df3
Validator 1 - https://arbiscan.io/address/0xe61fc6257160fCbe27cd81E95e3AE5A1835e451A
Validator 2 - https://arbiscan.io/address/0x4EC8378Fd09A6520974d4E0A75B964CaCa507E9A
Validator 3 - https://arbiscan.io/address/0x3566b35a8bFaf4A24a2e92335549060Ef1ef1900
Validator 4 - https://arbiscan.io/address/0x3057CF7F70065cdAcbdf91062d49BAb6CD260874
Zapper - https://zapper.xyz/bundle/0xdc790a53e50207861591622d349e989fef6f84bc,0xd04c1b09576aa4310e4768d8e9cd12fac3216f95,0x5e33e2cead338b1224ddd34636dac7563f97c300,0x015207adb81d3fb36e0db16822f1ca2528bdac7a?label=Enemy&id=0x10a1ee442025232acc4bfc63e39fc985bcbcaeb8
Enemy 1 - https://arbiscan.io/address/0xd04c1b09576aa4310e4768d8e9cd12fac3216f95
Enemy 2 - https://arbiscan.io/address/0x5E33e2CeAd338b1224DDd34636DaC7563f97C300

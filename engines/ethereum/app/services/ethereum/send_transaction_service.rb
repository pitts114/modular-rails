# frozen_string_literal: true

require 'eth'

module Ethereum
  class SendTransactionService
    class Error < StandardError; end

    NETWORK_ERRORS = [
      SocketError,
      Resolv::ResolvError,
      Errno::ENETUNREACH,
      Errno::EHOSTUNREACH,
      Errno::ECONNREFUSED,
      Errno::ECONNRESET,
      Errno::ETIMEDOUT,
      Socket::ResolutionError,
      Timeout::Error,
      (defined?(Net::OpenTimeout) ? Net::OpenTimeout : nil),
      (defined?(Net::ReadTimeout) ? Net::ReadTimeout : nil)
    ].compact.freeze

    def initialize(
      eth_client: Ethereum::ClientProvider.client,
      signer_service: Ethereum::TransactionSignerService.new,
      broadcast_service: Ethereum::TransactionBroadcastService.new,
      fee_estimator_service: Ethereum::FeeEstimatorService.new,
      gas_limit_service: Ethereum::GasLimitService.new,
      transaction_repository: Ethereum::TransactionRepository.new,
      transaction_status_publish_service: Ethereum::TransactionStatusPublishService.new,
      time: Time,
      sent_transaction_job: Ethereum::SendTransactionJob,
      kernel: Kernel
    )
      @signer_service = signer_service
      @broadcast_service = broadcast_service
      @fee_estimator_service = fee_estimator_service
      @gas_limit_service = gas_limit_service
      @eth_client = eth_client
      @transaction_repository = transaction_repository
      @transaction_status_publish_service = transaction_status_publish_service
      @time = time
      @send_transaction_job = sent_transaction_job
      @kernel = kernel
    end

    # holds transaction until the end to prevent sending 2+ transactions at the same time for the same address
    def call(address:, chain_id:)
      eth_tx_record = nil
      context = nil
      tx_hash = nil
      error = nil
      @transaction_repository.with_locked_pending_transaction(from: address, chain_id:) do |ethereum_transaction|
        return unless ethereum_transaction

        eth_tx_record = ethereum_transaction
        context = ethereum_transaction.context
        return unless ethereum_transaction.status == 'pending'

        # nonce here can be out of date. use the higher of what we have on record or what the client reports
        eth_client_nonce = nonce_from_eth_client(address)
        repo_nonce = nonce_from_repository(address:, chain_id:)
        nonce = [ eth_client_nonce, repo_nonce ].max

        fees = @fee_estimator_service.recommended_fees
        max_fee_per_gas = fees[:max_fee_per_gas]
        max_priority_fee_per_gas = fees[:max_priority_fee_per_gas]

        gas_limit = @gas_limit_service.call(
          chain_id: @eth_client.chain_id,
          from: ethereum_transaction.from,
          to: ethereum_transaction.to,
          data: ethereum_transaction.data,
          value: ethereum_transaction.value
        )

        tx = {
          chain_id: @eth_client.chain_id,
          nonce: nonce,
          to: ethereum_transaction.to,
          value: ethereum_transaction.value,
          gas_limit: gas_limit,
          priority_fee: max_priority_fee_per_gas,
          max_gas_fee: max_fee_per_gas,
          access_list: [],
          data: ethereum_transaction.data
        }

        signed_tx = @signer_service.sign_transaction(tx:, address: ethereum_transaction.from)
        tx_hash = @broadcast_service.send_transaction(signed_tx:)

        ethereum_transaction.update!(
          tx_hash:,
          nonce:,
          confirmed_at: @time.current,
          status: 'confirmed'
        )

      rescue IOError, Ethereum::RateLimitedClientWrapper::RateLimitedError => e
        error = e
      rescue StandardError => e
        unless  NETWORK_ERRORS.any? { |err| e.is_a?(err) }
          ethereum_transaction.update!(status: 'failed')
        end
        error = e
      end

      @transaction_status_publish_service.call(ethereum_transaction: eth_tx_record) if eth_tx_record.present?
      @send_transaction_job.perform_later(address, chain_id)
      raise error if error
      tx_hash
    rescue => e
      raise Error, "Failed to call contract: #{e.message} (#{e.class}) - id: #{eth_tx_record&.id} - context: #{context.inspect}"
    end

    private

    def nonce_from_eth_client(address)
      @eth_client.eth_get_transaction_count(address, "pending")["result"].to_i 16
    end

    def nonce_from_repository(address:, chain_id:)
      ethereum_transaction = @transaction_repository.confirmed_transaction_with_highest_nonce(from: address, chain_id:)
      return ethereum_transaction.nonce + 1 if ethereum_transaction.present?

      0
    end
  end
end

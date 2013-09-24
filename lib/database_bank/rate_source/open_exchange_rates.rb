require 'net/http'

class Money
  module Bank
    module DatabaseBank
      module RateSource

        # Service class to retrieve exchange rates from the EU Central Bank
        class OpenExchangeRates
          NAME = 'Open Exchange Rates'
          BASE_CURRENCY = 'USD'
          OER_RATES_URL = 'http://openexchangerates.org/api/latest.json?app_id='

          def self.app_id=(appid)
            @app_id = appid
          end

          def self.app_id
            @app_id || ''
          end

          def self.non_base_currencies
            DatabaseBank.currencies.select { |c| c != BASE_CURRENCY }
          end

          # Returns an array of exchange rate data, where each array member is a hash
          # with sourced_at, from_currency, to_currency, rate, and rate_source keys.
          def self.fetch_rates
            response = Net::HTTP.get_response(URI(OER_RATES_URL + app_id))
            unless response.is_a?(Net::HTTPSuccess)
              raise "Failed to fetch latest rates from Open Exchange Rates: #{response.code} (#{response.message})"
            end

            rate_data = JSON.parse(response.body)
            sourced_at = Time.at(Integer(rate_data['timestamp']))
            rates = [{ sourced_at: sourced_at, rate_source: NAME, from_currency: BASE_CURRENCY, to_currency: BASE_CURRENCY, rate: 1.0 }]

            rate_data['rates'].each do |code, rate|
              if non_base_currencies.include? code
                exchange_rate = Float(rate)
                rates << { sourced_at: sourced_at, rate_source: NAME, from_currency: BASE_CURRENCY, to_currency: code, rate: exchange_rate }
                rates << { sourced_at: sourced_at, rate_source: NAME, from_currency: code, to_currency: BASE_CURRENCY, rate: 1.0 / exchange_rate }
              end
            end

            # Now figure out all the other <-> other currency rates
            non_base_currencies.permutation(2).to_a.each do |pair|
              from_currency, to_currency = pair

              from_base_rate = rates.find { |rate| rate[:from_currency] == BASE_CURRENCY && rate[:to_currency] == from_currency }
              to_base_rate = rates.find { |rate| rate[:from_currency] == BASE_CURRENCY && rate[:to_currency] == to_currency }
              rate = to_base_rate[:rate] / from_base_rate[:rate]

              rates << { sourced_at: sourced_at, rate_source: NAME, from_currency: from_currency, to_currency: to_currency, rate: rate }
            end

            rates
          rescue => ex
            raise FetchError.new(ex.message)
          end
        end
      end
    end
  end
end

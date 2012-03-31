class Money
  module Bank
    module DatabaseBank
      module RateSource

        # Service class to retrieve exchange rates from the EU Central Bank
        class EuCentralBank
          NAME = 'EU Central Bank'
          ECB_RATES_URL = 'http://www.ecb.int/stats/eurofxref/eurofxref-daily.xml'

          def self.non_base_currencies
            DatabaseBank.currencies.select { |c| c != 'EUR' }
          end

          # Returns an array of exchange rate data, where each array member is a hash 
          # with sourced_at, from_currency, to_currency, rate, and rate_source keys.
          def self.fetch_rates
            doc = Nokogiri::XML(open(ECB_RATES_URL))
            date = doc.xpath('gesmes:Envelope/xmlns:Cube/xmlns:Cube').first['time']
            rate_data = doc.xpath('gesmes:Envelope/xmlns:Cube/xmlns:Cube//xmlns:Cube')
            sourced_at = Time.parse("#{date} 00:00:00 UTC")
            rates = [{ sourced_at: sourced_at, rate_source: NAME, from_currency: 'EUR', to_currency: 'EUR', rate: 1.0 }]
            
            # Add all the rates for EUR <-> other currency 
            rate_data.each do |rate|
              to_currency = rate['currency']
              if DatabaseBank.currencies.include? to_currency
                rates << { sourced_at: sourced_at, rate_source: NAME, from_currency: 'EUR', to_currency: to_currency, rate: rate['rate'].to_f }
                rates << { sourced_at: sourced_at, rate_source: NAME, from_currency: to_currency, to_currency: 'EUR', rate: 1.0 / rate['rate'].to_f }
              end
            end

            # Now figure out all the other <-> other currency rates
            non_base_currencies.permutation(2).to_a.each do |pair|
              from_currency, to_currency = pair

              from_base_rate = rates.find { |rate| rate[:from_currency] == "EUR" && rate[:to_currency] == from_currency }
              to_base_rate = rates.find { |rate| rate[:from_currency] == "EUR" && rate[:to_currency] == to_currency }
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

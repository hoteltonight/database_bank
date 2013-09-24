require 'money'
require 'open-uri'
require 'nokogiri'
require "database_bank/version"
require 'database_bank/database_exchange'
require 'database_bank/rate_source'
require 'database_bank/rate_source/eu_central_bank'
require 'database_bank/rate_source/open_exchange_rates'


class Money
  module Bank

    module DatabaseBank
      class InvalidCurrencyCode < StandardError ; end

      extend self

      # Configure/define which currencies you want to store exchange rates for
      def currencies=(currencies)
        @currencies = []
        currencies.each do |currency|
          if currency =~ /^[A-Z]{3}$/i
            @currencies << currency.upcase
          else
            raise InvalidCurrencyCode.new("#{currency} is invalid, must be 3 letter ISO code")
          end
        end
      end

      # Returns an array of the currencies the store is paying attention to
      def currencies
        @currencies || []
      end

      # Configure the source of the exchange rates
      #
      # source - a class that implements the fetch_rates class method to return exchange rate data
      def rate_source=(source)
        @rate_source = source
      end

      # Returns the current rate source - defaults to EuCentralBank
      def rate_source
        @rate_source ||= DatabaseBank::RateSource::EuCentralBank
      end

      def exchange_rate_model=(model_class)
        @exchange_rate_model = model_class
      end

      def exchange_rate_model
        @exchange_rate_model
      end

      def update_rates
        rates = rate_source.fetch_rates()
        rates.each { |rate| exchange_rate_model.create!(rate) }
      end
    end

  end
end

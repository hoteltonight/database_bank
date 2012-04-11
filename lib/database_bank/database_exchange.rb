class Money
  module Bank

    module DatabaseBank

      class DatabaseExchange < Money::Bank::VariableExchange

        # Retrieve the rate for the given currencies
        #
        # from_currency - a Currency object representing the currency being converted from
        # to_currency - a Currency or String with the ISO code of the currency to convert to
        #
        def get_rate(from_currency, to_currency)
          rate = DatabaseBank.exchange_rate_model.where(from_currency: from_currency.iso_code).where(to_currency: to_currency.to_s).order(:sourced_at).last
          raise UnknownRate unless rate
          rate.rate
        end
      end

    end

  end
end

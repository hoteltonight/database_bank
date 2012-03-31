class Money
  module Bank

    module DatabaseBank

      class DatabaseExchange < Money::Bank::VariableExchange
        def get_rate(from, to)
          rate = DatabaseBank.exchange_rate_model.where(from_currency: from).where(to_currency: to).order(:sourced_at).last
          raise UnknownRate unless rate
          rate.rate
        end
      end

    end

  end
end

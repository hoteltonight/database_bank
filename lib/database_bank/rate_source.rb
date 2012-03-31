# Common RateSource errors

# Raised when a RateSource encounters an error fetching rates
class Money
  module Bank
    module DatabaseBank
      module RateSource
  
        class FetchError < StandardError ; end
  
      end
    end
  end
end

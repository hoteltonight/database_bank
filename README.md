# DatabaseBank

This gem is an exchange rate implementation for use with the Money gem. In 
particular, it retrieves rates from an exchange rate service, and then stores 
those rates in your database via an ActiveModel compliant model class you 
specify. This model needs to have from_currency, to_currency, rate, sourced_at, 
and rate_source attributes. The expected use of this is to harvest exchange rates on 
a consistent schedule, and then persist them so that you know what exchange 
rate you were using at a given time (e.g. for accounting or historical purposes).

## Installation

Add this line to your application's Gemfile:

    gem 'database_bank'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install database_bank

## Usage

You must configure the rate source, model class, and currencies you wish to track:

    DatabaseBank.currencies = %w(USD EUR GBP CAD AUD)
    DatabaseBank.exchange_rate_model = ExchangeRate
    DatabaseBank.rate_source = DatabaseBank::RateSource::EuCentralBank

You can use one of the included rate sources, or any class that implements a fetch_rates
class method that complies with the interface.

Then, to harvest rates and store them in your ExchangeRate (or otherwise configured)
model, do:

    DatabaseBank.update_rates

Finally, set the bank to use for the Money gem:

    Money.default_bank = DatabaseExchange.new

You can then use the Money gem's conversion methods.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

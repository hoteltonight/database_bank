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

You can use one of the included rate sources, or any class that implements a `fetch_rates`
class method that complies with the interface (see Rate Sources below).

Then, to harvest rates and store them in your `ExchangeRate` (or otherwise configured)
model, do:

    Money::Bank::DatabaseBank.update_rates

Finally, set the bank to use for the Money gem:

    Money.default_bank = Money::Bank::DatabaseBank::DatabaseExchange.new

You can then use the Money gem's conversion methods.

## Rate Sources

To implement a different rate source, create a class that provides a `fetch_rates` method
which returns an array of rate information hashes. This must return all permutations of
rates you will need to do currency conversions. For example, most exchange rate web
services provide rates based on a base currency. Thus, you need to calculate the inverse
rates, as well as the permutations between currencies not including the base currency.

See the `EuCentralBank` implementation for an example. It fetches the rates, which use the
EUR as the base currency. It then sets those, calculates the inverse, then figures out
rates for say USD to GBP or AUD to CAD, etc.

The hashes in the return array should include the fields your exchange rate model will
use as they will be passed through en masse.

### Open Exchange Rates source

This source requires an APP ID, supplied when you purchase an Open Exchange Rates account/plan.
You should configure this by doing:

Money::Bank::DatabaseBank::RateSource::OpenExchangeRates.app_id = 'YourAppIdGoesHere'


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

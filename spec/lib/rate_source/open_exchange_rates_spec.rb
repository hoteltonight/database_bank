require 'spec_helper'

describe Money::Bank::DatabaseBank::RateSource::OpenExchangeRates do
  before do
    Money::Bank::DatabaseBank.currencies = %w(USD AUD EUR)
  end

  it "should fetch rates for configured currencies" do
    test_data = File.open(File.dirname(__FILE__) + '/../../open_exchange_latest.json').read
    fixture = OpenStruct.new(body: test_data)
    Net::HTTP.should_receive(:get_response).and_return(fixture)
    fixture.should_receive(:is_a?).with(Net::HTTPSuccess).and_return(true)
    rates = Money::Bank::DatabaseBank::RateSource::OpenExchangeRates.fetch_rates

    fixture_data = JSON.parse(fixture.body)
    date = Time.at fixture_data['timestamp']
    aud = fixture_data['rates']['AUD']
    eur = fixture_data['rates']['EUR']
    source = Money::Bank::DatabaseBank::RateSource::OpenExchangeRates::NAME

    rates.should =~ [
      { sourced_at: date, rate_source: source, from_currency: 'USD', to_currency: 'USD', rate: 1.0 },
      { sourced_at: date, rate_source: source, from_currency: 'USD', to_currency: 'AUD', rate: aud },
      { sourced_at: date, rate_source: source, from_currency: 'USD', to_currency: 'EUR', rate: eur },
      { sourced_at: date, rate_source: source, from_currency: 'EUR', to_currency: 'USD', rate: 1.0/eur },
      { sourced_at: date, rate_source: source, from_currency: 'EUR', to_currency: 'AUD', rate: aud/eur },
      { sourced_at: date, rate_source: source, from_currency: 'AUD', to_currency: 'EUR', rate: eur/aud },
      { sourced_at: date, rate_source: source, from_currency: 'AUD', to_currency: 'USD', rate: 1.0/aud }
    ]
  end
end

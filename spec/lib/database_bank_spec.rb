require 'spec_helper'

# Dummy class - this model should be defined in the code that uses this gem
class ExchangeRate; end

describe DatabaseBank do
  before do
    Money::Bank::DatabaseBank.exchange_rate_model = ExchangeRate
  end

  describe "configuration" do
    it "should default the rate source to the EuCentralBank" do
      Money::Bank::DatabaseBank.rate_source.should == Money::Bank::DatabaseBank::RateSource::EuCentralBank
    end

    it "should use configured rate source" do
      Money::Bank::DatabaseBank.rate_source = ExchangeRate
      Money::Bank::DatabaseBank.rate_source.should == ExchangeRate
    end

    it "should reject improperly formed currency ISO codes" do
      lambda { Money::Bank::DatabaseBank.currencies = %w(USD gbp xXx) }.should_not raise_error
      lambda { Money::Bank::DatabaseBank.currencies = %w(USD D12) }.should raise_error
      lambda { Money::Bank::DatabaseBank.currencies = %w(123 abc) }.should raise_error
    end
  end

  describe "update_rates" do
    before do
      # Define the currencies we care about for this use
      Money::Bank::DatabaseBank.currencies = %w(USD CAD EUR GBP AUD)
    end

    context "using EuCentralBank as rate source" do
      before do
        Money::Bank::DatabaseBank.rate_source = Money::Bank::DatabaseBank::RateSource::EuCentralBank
      end

      it "should retrieve current rates and store them via ExchangeRate models" do
        now = Time.now.utc

        # not as complete as what we'd actually get back, but sufficient for stubbing
        rate_data = 
          [ { sourced_at: now, rate_source: 'test', from_currency: 'EUR', to_currency: 'EUR', rate: 1.0 },
            { sourced_at: now, rate_source: 'test', from_currency: 'EUR', to_currency: 'USD', rate: 1.2345 },
            { sourced_at: now, rate_source: 'test', from_currency: 'EUR', to_currency: 'CAD', rate: 1.4567 },
            { sourced_at: now, rate_source: 'test', from_currency: 'EUR', to_currency: 'AUD', rate: 1.8901 },
            { sourced_at: now, rate_source: 'test', from_currency: 'EUR', to_currency: 'GBP', rate: 1.0019 } ]

        Money::Bank::DatabaseBank::RateSource::EuCentralBank.should_receive(:fetch_rates).and_return(rate_data)

        rate_data.each { |data| ExchangeRate.should_receive(:create!).with(data).and_return(true) }

        lambda { Money::Bank::DatabaseBank.update_rates() }.should_not raise_error
      end
    end
  end  

end

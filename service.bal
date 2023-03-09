import ballerinax/exchangerates;
import ramith/countryprofile;
import ballerina/log;
import ballerina/http;

configurable string exchangeRatesAPIKey = ?;
configurable string clientSecret = ?;
configurable string clientId = ?;

type PricingInfo record {
    string currencyCode;
    string displayName;
    decimal amount;
};

# A service representing a network-accessible API
# bound to port `9090`.
service / on new http:Listener(9090) {

    resource function get convert(string target = "AUD", string base = "USD", decimal amount = 1) returns PricingInfo|error {
        log:printInfo("new request for amount " + amount.toString());

        countryprofile:Client countryprofileEp = check new (config = {
            auth: {
                clientId: clientId,
                clientSecret: clientSecret
            }
        });
        countryprofile:Currency getCurrencyCodeResponse = check countryprofileEp->getCurrencyCode(code = target);
        exchangerates:Client exchangeratesEp = check new ();
        exchangerates:CurrencyExchangeInfomation getExchangeRateForResponse = check exchangeratesEp->getExchangeRateFor(apikey = exchangeRatesAPIKey, baseCurrency = base);
 
        PricingInfo summary = {
            currencyCode: target,
            displayName: getCurrencyCodeResponse.displayName,
            amount: amount * <decimal>getExchangeRateForResponse.conversion_rates[target]
        };
 
        return summary;
    }
}

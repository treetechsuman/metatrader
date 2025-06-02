#ifndef BOLLINGERBAND_MQH
#define BOLLINGERBAND_MQH

string BollingerBandSignal(int maPeriod, double deviation)
{
    MqlRates priceInfo[];
    ArraySetAsSeries(priceInfo, true);

    // Copy LAST 3 CLOSED BARS (index 1 = most recent closed bar)
    if (CopyRates(_Symbol, _Period, 0, 3, priceInfo) < 3)
    {
        Print("Error: Failed to copy Price values.");
        return "NoTrade";
    }

    // Bollinger Bands handle with corrected parameters
    int handleBollinger = iBands(_Symbol, _Period, maPeriod, 0, deviation, PRICE_CLOSE);
    if (handleBollinger == INVALID_HANDLE)
    {
        Print("Error: Failed to create Bollinger Bands handle. LastError: ", GetLastError());
        return "NoTrade";
    }

    // Get Bollinger Bands data
    double upperBandArray[], lowerBandArray[];
    ArraySetAsSeries(upperBandArray, true);
    ArraySetAsSeries(lowerBandArray, true);

    // Copy data for 3 bars (index 1 = most recent closed bar)
    if (CopyBuffer(handleBollinger, 1, 0, 3, upperBandArray) < 3 ||
        CopyBuffer(handleBollinger, 2, 0, 3, lowerBandArray) < 3)
    {
        Print("Error: Failed to copy Bollinger Bands values. LastError: ", GetLastError());
        IndicatorRelease(handleBollinger);
        return "NoTrade";
    }

    IndicatorRelease(handleBollinger);

    // Use CLOSED BAR data (index 1 = previous bar, index 2 = two bars back)
    double currentClose = priceInfo[1].close;    // Most recent closed candle
    double previousClose = priceInfo[2].close;   // Candle before that

    double currentUpper = upperBandArray[1];
    double currentLower = lowerBandArray[1];
    double previousUpper = upperBandArray[2];
    double previousLower = lowerBandArray[2];

    // Buy: Price exits lower band and re-enters
    if (previousClose < previousLower && currentClose > currentLower)
    {
        return "BUY";
    }

    // Sell: Price exits upper band and re-enters
    if (previousClose > previousUpper && currentClose < currentUpper)
    {
        return "SELL";
    }

    return "NoTrade";
}

#endif
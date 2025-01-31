#ifndef BOLLINGERBAND_MQH
#define BOLLINGERBAND_MQH

string BollingerBandSignal(int maPeriod, double deviation)
{
    MqlRates priceInfo[];
    double Ask = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK), _Digits);
    double Bid = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits);

    ArraySetAsSeries(priceInfo, true);

    if (CopyRates(_Symbol, _Period, 0, 3, priceInfo) <= 0)
    {
        Print("Error: Failed to copy Price values.");
        return "NoTrade";
    }

    // Ensure enough bars exist
    if (Bars(_Symbol, _Period) < maPeriod + 1)
    {
        Print("Error: Not enough bars available.");
        return "NoTrade";
    }

    // Bollinger Bands arrays
    double upperBandArray[], lowerBandArray[];

    // Create Bollinger Bands handle
    int handleBollinger = iBands(_Symbol, _Period, 20, 0, 2, PRICE_CLOSE);

    if (handleBollinger == INVALID_HANDLE)
    {
        Print("Error: Failed to create Bollinger Bands handle. LastError: ", GetLastError());
        return "NoTrade";
    }

    // Resize arrays before copying buffer
    ArrayResize(upperBandArray, 3);
    ArrayResize(lowerBandArray, 3);
    
    ArraySetAsSeries(upperBandArray, true);
    ArraySetAsSeries(lowerBandArray, true);

    // Copy Bollinger Band values
    int copiedUpper = CopyBuffer(handleBollinger, 1, 0, 3, upperBandArray);
    int copiedLower = CopyBuffer(handleBollinger, 2, 0, 3, lowerBandArray);

    if (copiedUpper <= 0 || copiedLower <= 0)
    {
        Print("Error: Failed to copy Bollinger Bands values. LastError: ", GetLastError());
        IndicatorRelease(handleBollinger);
        return "NoTrade";
    }

    // Ensure arrays contain enough elements
    if (ArraySize(upperBandArray) < 2 || ArraySize(lowerBandArray) < 2)
    {
        Print("Error: Bollinger Bands array has insufficient data.");
        IndicatorRelease(handleBollinger);
        return "NoTrade";
    }

    // Release indicator handle
    IndicatorRelease(handleBollinger);

    double currentUpperBandValue = upperBandArray[0];
    double currentLowerBandValue = lowerBandArray[0];

    double previousUpperBandValue = upperBandArray[1];
    double previousLowerBandValue = lowerBandArray[1];

    // Buy condition
    if (priceInfo[0].close < currentLowerBandValue &&
        priceInfo[1].close < previousLowerBandValue)
    {
        return "BUY";
    }

    // Sell condition
    if (priceInfo[0].close > currentUpperBandValue &&
        priceInfo[1].close > previousUpperBandValue)
    {
        return "SELL";
    }

    return "NoTrade";
}

#endif

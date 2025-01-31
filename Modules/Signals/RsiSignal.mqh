#ifndef RSISIGNAL_MQH
#define RSISIGNAL_MQH

string RsiSignal(int rsiPeriod, int rsiBuyLevel, int rsiSellLevel)
{
    // Create an array to store RSI values
    double rsiArray[];

    // Create the RSI indicator handle
    int handleRSI = iRSI(_Symbol, PERIOD_CURRENT, rsiPeriod, PRICE_CLOSE);

    // Check if the RSI handle is valid
    if (handleRSI == INVALID_HANDLE)
    {
        Print("Error: Failed to create RSI indicator handle.");
        return "NoTrade";
    }

    // Resize and sort the array
    ArraySetAsSeries(rsiArray, true);

    // Copy RSI values into the array (ensure at least 2 values are copied)
    if (CopyBuffer(handleRSI, 0, 0, 2, rsiArray) <= 0)  // Fetch only the latest two values
    {
        Print("Error: Failed to copy RSI values.");
        IndicatorRelease(handleRSI);  // Release handle before returning
        return "NoTrade";
    }

    // Release the RSI indicator handle to prevent memory leaks
    IndicatorRelease(handleRSI);

    // Debugging print statements
    //PrintFormat("RSI[1]: %.2f, RSI[0]: %.2f", rsiArray[1], rsiArray[0]);

    // Ensure we use RSI[1] (previous candle) for a confirmed signal
    if ( rsiArray[0] > rsiBuyLevel)
    {
        return "BUY";  // RSI crossed above buy level (bullish signal)
    }
    if ( rsiArray[0] < rsiSellLevel)
    {
        return "SELL";  // RSI crossed below sell level (bearish signal)
    }

    return "NoTrade";  // No valid crossover detected
}

#endif
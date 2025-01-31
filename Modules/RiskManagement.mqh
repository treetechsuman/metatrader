#ifndef RISK_MANAGEMENT_MQH
#define RISK_MANAGEMENT_MQH

// Function to calculate lot size based on risk percentage and stop-loss
double CalculateLotSize(double riskPercentage, double stopLossPips)
{
    // Ensure inputs are valid
    if (riskPercentage <= 0 || stopLossPips <= 0)
    {
        Print("Error: Risk percentage and stop-loss pips must be greater than zero.");
        return 0.0;
    }

    // Get account details
    double accountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
    double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
    double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
    double pointValue = SymbolInfoDouble(_Symbol, SYMBOL_POINT);

    if (tickValue <= 0 || tickSize <= 0 || pointValue <= 0)
    {
        Print("Error: Invalid symbol parameters (tickValue, tickSize, or pointValue).");
        return 0.0;
    }

    // Calculate risk amount in currency
    double riskAmount = (riskPercentage / 100.0) * accountBalance;
    //Print("Risk Amount: ",riskAmount);

    // Calculate the value of 1 pip in the deposit currency
    double pipValue = (tickValue / tickSize) * pointValue;

    if (pipValue <= 0)
    {
        Print("Error: Pip value is invalid.");
        return 0.0;
    }

    // Calculate lot size
    double lotSize = riskAmount / (stopLossPips * pipValue);

    // Adjust lot size to meet broker's minimum and step requirements
    double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
    double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
    double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);

    if (lotSize < minLot)
    {
        PrintFormat("Warning: Calculated lot size (%.2f) is less than the minimum allowed (%.2f). Adjusting to minimum lot size.", lotSize, minLot);
        lotSize = minLot;
    }
    else if (lotSize > maxLot)
    {
        PrintFormat("Warning: Calculated lot size (%.2f) exceeds the maximum allowed (%.2f). Adjusting to maximum lot size.", lotSize, maxLot);
        lotSize = maxLot;
    }

    // Round lot size to the nearest step
    lotSize = MathFloor(lotSize / lotStep) * lotStep;

    return lotSize;
}

#endif

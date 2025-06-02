#ifndef RISK_MANAGEMENT_MQH
#define RISK_MANAGEMENT_MQH

// Function to calculate lot size based on risk percentage and stop-loss (in pips)
double CalculateLotSize(double riskPercentage, double stopLossPips)
{
    // Validate inputs
    if (riskPercentage <= 0 || stopLossPips <= 0)
    {
        Print("Error: Risk percentage and stop-loss pips must be greater than zero.");
        return 0.0;
    }

    // Get account balance and symbol details
    double accountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
    double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
    double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
    double pointValue = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
    int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);

    if (tickValue <= 0 || tickSize <= 0 || pointValue <= 0)
    {
        Print("Error: Invalid symbol parameters (tickValue, tickSize, or pointValue).");
        return 0.0;
    }

    // Calculate points per pip (adjust for 3/5-digit symbols)
    double pointsPerPip = (digits == 3 || digits == 5) ? 10 : 1;
    double stopLossPoints = stopLossPips * pointsPerPip;

    // Calculate risk amount in currency
    double riskAmount = (riskPercentage / 100.0) * accountBalance;

    // Calculate value per point in deposit currency
    double valuePerPoint = (tickValue / tickSize) * pointValue;

    if (valuePerPoint <= 0)
    {
        Print("Error: Value per point is invalid.");
        return 0.0;
    }

    // Calculate lot size
    double lotSize = riskAmount / (stopLossPoints * valuePerPoint);

    // Adjust to broker's lot size constraints
    double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
    double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
    double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);

    lotSize = MathMin(MathMax(lotSize, minLot), maxLot); // Clamp to min/max
    lotSize = MathRound(lotSize / lotStep) * lotStep;    // Round to step

    return lotSize;
}

#endif
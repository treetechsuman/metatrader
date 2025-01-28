#ifndef TRADE_EXECUTION_MQH
#define TRADE_EXECUTION_MQH

#include <Trade\Trade.mqh> // Include the CTrade class

class TradeExecution
{
private:
    CTrade trade; // Instance of the CTrade class

public:
    // Method to execute a trade
    bool OpenTrade(ENUM_ORDER_TYPE type, double lotSize, double stopLossPips, double takeProfitPips)
    {
        double price = (type == ORDER_TYPE_BUY) ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : SymbolInfoDouble(_Symbol, SYMBOL_BID);
        double stopLoss = 0.0, takeProfit = 0.0;

        // Calculate Stop Loss and Take Profit
        if (type == ORDER_TYPE_BUY)
        {
            stopLoss = price - stopLossPips * _Point;
            takeProfit = price + takeProfitPips * _Point;
        }
        else if (type == ORDER_TYPE_SELL)
        {
            stopLoss = price + stopLossPips * _Point;
            takeProfit = price - takeProfitPips * _Point;
        }

        // Execute the trade
        if (trade.PositionOpen(_Symbol, type, lotSize, price, stopLoss, takeProfit))
        {
            PrintFormat("Trade opened: %s, Lot: %.2f, SL: %.5f, TP: %.5f", EnumToString(type), lotSize, stopLoss, takeProfit);
            return true;
        }
        else
        {
            PrintFormat("Failed to open trade. Error: %d", GetLastError());
            return false;
        }
    }

    // Method to close all trades for the symbol
    bool CloseAllTrades()
    {
        if (trade.PositionClose(_Symbol))
        {
            Print("All trades closed successfully.");
            return true;
        }
        else
        {
            PrintFormat("Failed to close trades. Error: %d", GetLastError());
            return false;
        }
    }
};

#endif

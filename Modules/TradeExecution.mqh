#ifndef TRADE_EXECUTION_MQH
#define TRADE_EXECUTION_MQH

#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh> // Required for MqlTick and SymbolInfoTick()

class TradeExecution
{
private:
    CTrade trade;
    CSymbolInfo symbolInfo; // Helper for symbol properties

public:
    bool OpenTrade(ENUM_ORDER_TYPE type, double lotSize, double stopLossPips, double takeProfitPips)
    {
        // Get current price using SymbolInfoTick (MQL5 standard)
        MqlTick lastTick;
        if (!SymbolInfoTick(_Symbol, lastTick)) // Fetch current bid/ask
        {
            Print("Failed to get tick data. Error: ", GetLastError());
            return false;
        }

        double price = (type == ORDER_TYPE_BUY) ? lastTick.ask : lastTick.bid;

        // Get symbol properties
        symbolInfo.Name(_Symbol);
        if (!symbolInfo.RefreshRates()) // Update symbol data
        {
            Print("Failed to refresh rates. Error: ", GetLastError());
            return false;
        }

        // Normalize price, lot size, and calculate SL/TP
        price = symbolInfo.NormalizePrice(price);
        double point = symbolInfo.Point();
        int digits = symbolInfo.Digits();

        double stopLoss = 0.0, takeProfit = 0.0;

        // Calculate SL/TP (only if values > 0)
        if (stopLossPips > 0)
        {
            stopLoss = (type == ORDER_TYPE_BUY) ?
                       price - stopLossPips * point :
                       price + stopLossPips * point;
            stopLoss = symbolInfo.NormalizePrice(stopLoss);
        }

        if (takeProfitPips > 0)
        {
            takeProfit = (type == ORDER_TYPE_BUY) ?
                         price + takeProfitPips * point :
                         price - takeProfitPips * point;
            takeProfit = symbolInfo.NormalizePrice(takeProfit);
        }

        // Validate SL/TP distances
        if (stopLossPips > 0)
        {
            double minSL = symbolInfo.StopsLevel() * point;
            if (MathAbs(price - stopLoss) < minSL)
            {
                PrintFormat("SL too close. Min: %f, Actual: %f",
                           minSL, MathAbs(price - stopLoss));
                return false;
            }
        }

        // Execute trade
        if (trade.PositionOpen(_Symbol, type, lotSize, price, stopLoss, takeProfit))
        {
            Print("Trade opened successfully");
            return true;
        }
        else
        {
            PrintFormat("Failed to open trade. Error: %d", GetLastError());
            return false;
        }
    }

    bool CloseAllTrades()
    {
        if(trade.PositionClose(_Symbol))
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
    
   
   
   bool CloseBuyTrades()
   {
       bool all_closed = true;
   
       for(int i = PositionsTotal() - 1; i >= 0; i--)
       {
           ulong ticket = PositionGetTicket(i);
           if(ticket == 0)
           {
               Print("❌ Failed to get position ticket. Error: ", GetLastError());
               all_closed = false;
               continue;
           }
   
           if(PositionSelectByTicket(ticket))
           {
               string symbol = PositionGetString(POSITION_SYMBOL);
               ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
   
               if(symbol == _Symbol && type == POSITION_TYPE_BUY)
               {
                   // Attempt to close the SELL position
                   if(trade.PositionClose(ticket))
                   {
                       //PrintFormat("✅ BUY trade (Ticket: %I64d) closed successfully.", ticket);
                   }
                   else
                   {
                       PrintFormat("❌ Failed to close BUY trade (Ticket: %I64d). Error: %d", ticket, GetLastError());
                       all_closed = false;
                   }
               }
           }
           else
           {
               PrintFormat("❌ Failed to select position (Ticket: %I64d). Error: %d", ticket, GetLastError());
               all_closed = false;
           }
       }
   
       //Print(all_closed ? "✅ All BUY trades closed successfully." : "Some BUY trades failed to close.");
       return all_closed;
   }
   
  bool CloseSellTrades()
   {
       bool all_closed = true;
   
       for(int i = PositionsTotal() - 1; i >= 0; i--)
       {
           ulong ticket = PositionGetTicket(i);
           if(ticket == 0)
           {
               Print("❌ Failed to get position ticket. Error: ", GetLastError());
               all_closed = false;
               continue;
           }
   
           if(PositionSelectByTicket(ticket))
           {
               string symbol = PositionGetString(POSITION_SYMBOL);
               ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
   
               if(symbol == _Symbol && type == POSITION_TYPE_SELL)
               {
                   // Attempt to close the SELL position
                   if(trade.PositionClose(ticket))
                   {
                       PrintFormat("✅ SELL trade (Ticket: %I64d) closed successfully.", ticket);
                   }
                   else
                   {
                       PrintFormat("❌ Failed to close SELL trade (Ticket: %I64d). Error: %d", ticket, GetLastError());
                       all_closed = false;
                   }
               }
           }
           else
           {
               PrintFormat("❌ Failed to select position (Ticket: %I64d). Error: %d", ticket, GetLastError());
               all_closed = false;
           }
       }
   
       //Print(all_closed ? "✅ All SELL trades closed successfully." : "⚠️ Some SELL trades failed to close.");
       return all_closed;
   }
   
   // Function to apply trailing stop
   void ApplyTrailingStop(ulong ticket, double trailStartPips, double trailStopPips)
   {
       // Check if the ticket is valid
       if (ticket == 0)
       {
           Print("Error: Invalid ticket number.");
           return;
       }
   
       // Select the position by ticket
       if (PositionSelectByTicket(ticket))
       {
           // Get position details
           double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
           double currentStopLoss = PositionGetDouble(POSITION_SL);
           double currentPrice = PositionGetDouble(POSITION_PRICE_CURRENT);
           double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
           double pipSize = point * 10; // Assuming 1 pip = 10 points (for 5-digit brokers)
   
           // Calculate trail start and stop levels in price terms
           double trailStartLevel = (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) ?
                                    openPrice + trailStartPips * pipSize :
                                    openPrice - trailStartPips * pipSize;
   
           double newStopLoss = (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) ?
                                currentPrice - trailStopPips * pipSize :
                                currentPrice + trailStopPips * pipSize;
   
           // Check if the price has moved in favor by trailStartPips
           if ((PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY && currentPrice >= trailStartLevel) ||
               (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL && currentPrice <= trailStartLevel))
           {
               // Check if the new stop loss is better than the current one
               if ((PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY && newStopLoss > currentStopLoss) ||
                   (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL && newStopLoss < currentStopLoss))
               {
                   // Modify the position with the new stop loss
                   if (trade.PositionModify(ticket, newStopLoss, PositionGetDouble(POSITION_TP)))
                   {
                       PrintFormat("✅ Trailing stop updated for ticket %I64d. New SL: %f", ticket, newStopLoss);
                   }
                   else
                   {
                       PrintFormat("❌ Failed to update trailing stop for ticket %I64d. Error: %d", ticket, GetLastError());
                   }
               }
           }
       }
       else
       {
           PrintFormat("❌ Failed to select position with ticket %I64d. Error: %d", ticket, GetLastError());
       }
   }

};

#endif
//+------------------------------------------------------------------+
//|                                             MyExpertAdvaisor.mq5 |
// Input Parameters
#include "Modules/Signal.mqh";
#include "Modules/RiskManagement.mqh";
#include "Modules/TradeExecution.mqh";
#include "Modules/Utils.mqh";
#include "Modules/ChartComment.mqh"

// Global instance of the TradeExecution class
TradeExecution tradeExec;
ChartComment chartComment;

input double LOTSize = 0.01;
input int STOPLoss = 100;
input int TAKEProfit = 200;

input int EMAFastPeriod = 10;       // Fast EMA period
input int EMASlowPeriod = 50;       // Slow EMA period
input int EMA_Very_Slow_Period  = 200;       //  EMA_200 


input int RSIPeriod = 14;            // RSI period
input double RSIBuyLevel = 55;      // RSI level for buy
input double RSISellLevel = 45;     // RSI level for sell

input int RISKPercentage = 2;




int OnInit()
{
    Print("Expert Advisor Initialized");
    // Example: Display a static message
    chartComment.Show("EA Status", "Hello, MQL5!");
    return INIT_SUCCEEDED;
}

void OnTick()
{
   // Example: Display real-time dynamic information
    string messages[];
    ArrayResize(messages, 3);
    messages[0] = "Symbol: " + _Symbol;
    messages[1] = "Bid: " + DoubleToString(SymbolInfoDouble(_Symbol, SYMBOL_BID), 5);
    messages[2] = "Ask: " + DoubleToString(SymbolInfoDouble(_Symbol, SYMBOL_ASK), 5);
    
    chartComment.Show("Market Information", messages, ArraySize(messages));
    
    
    string signal = EmaCrossoverSignal(EMAFastPeriod,EMASlowPeriod);
    Comment(signal);
    double dynamicLotSize = CalculateLotSize(RISKPercentage,STOPLoss);
    if (signal == "BUY" && PositionsTotal() == 0)  // Buy Signal
    {
         
         tradeExec.OpenTrade(ORDER_TYPE_BUY,dynamicLotSize,STOPLoss,TAKEProfit);
         Print("BUY Signal");
         
        //double risk = CalculateRisk(LotSize);
        //OpenTrade(ORDER_TYPE_BUY, LotSize, StopLoss, TakeProfit);
    }
    else if (signal == "SELL" && PositionsTotal() == 0)  // Sell Signal
    {
      tradeExec.OpenTrade(ORDER_TYPE_SELL,dynamicLotSize,STOPLoss,TAKEProfit);
      Print("Sell Signal");
        //double risk = CalculateRisk(LotSize);
        //OpenTrade(ORDER_TYPE_SELL, LotSize, StopLoss, TakeProfit);
    }
}

void OnDeinit(const int reason)
{
    Print("Expert Advisor Deinitialized");
}

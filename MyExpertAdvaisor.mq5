//+------------------------------------------------------------------+
//|                                             MyExpertAdvaisor.mq5 |
// Input Parameters
#include "Modules/Signal.mqh";
#include "Modules/RiskManagement.mqh";
#include "Modules/TradeExecution.mqh";
#include "Modules/Utils.mqh";
#include "Modules/ChartComment.mqh";

// Global instance of the TradeExecution class
TradeExecution tradeExec;
ChartComment chartComment;

input double LOTSize = 0.01;
input int STOPLoss = 100;
input int TAKEProfit = 200;

input int EMAFastPeriod = 5;       // Fast EMA period
input int EMASlowPeriod = 13;       // Slow EMA period
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
// Store the last known bar count
int lastBarCount = 0;
void OnTick()
{
   string emaSignal = EmaSignal(EMAFastPeriod,EMASlowPeriod);
   string rsiSignal = RsiSignal(RSIPeriod,RSIBuyLevel,RSISellLevel);
   // Example: Display real-time dynamic information
    string messages[];
    ArrayResize(messages, 5);
    messages[0] = "Symbol: " + _Symbol;
    messages[1] = "Bid: " + DoubleToString(SymbolInfoDouble(_Symbol, SYMBOL_BID), 5);
    messages[2] = "Ask: " + DoubleToString(SymbolInfoDouble(_Symbol, SYMBOL_ASK), 5);
    messages[3] = "Ema Signal: " + emaSignal;
    messages[4] = "Rsi Signal: " + rsiSignal;
    
    chartComment.Show("Market Information", messages, ArraySize(messages));
    
    
    //close trade if there is already open trade and crossover happen
     // Get the current bar count
    int currentBarCount = Bars(_Symbol, PERIOD_CURRENT);

    // Check if a new bar has appeared
    if (currentBarCount > lastBarCount)
    {
        Print("New candle detected!");
        //if((signal=="BUY"||signal=="SELL")&&PositionsTotal()>0){
        // tradeExec.CloseAllTrades();
        //}
        
        lastBarCount = currentBarCount; // Update the last known bar count
        //Comment(signal);
    double dynamicLotSize = CalculateLotSize(RISKPercentage,STOPLoss);
    if (emaSignal == "BUY" && rsiSignal == "BUY" && PositionsTotal() == 0)  // Buy Signal
    {
         
         tradeExec.OpenTrade(ORDER_TYPE_BUY,dynamicLotSize,STOPLoss,TAKEProfit);
         //Print("BUY Signal");
         
        //double risk = CalculateRisk(LotSize);
        //OpenTrade(ORDER_TYPE_BUY, LotSize, StopLoss, TakeProfit);
    }
    else if (emaSignal == "SELL" && rsiSignal == "SELL" && PositionsTotal() == 0)  // Sell Signal
    {
      tradeExec.OpenTrade(ORDER_TYPE_SELL,dynamicLotSize,STOPLoss,TAKEProfit);
      //Print("Sell Signal");
        //double risk = CalculateRisk(LotSize);
        //OpenTrade(ORDER_TYPE_SELL, LotSize, StopLoss, TakeProfit);
    }
    }
    
}

void OnDeinit(const int reason)
{
    Print("Expert Advisor Deinitialized");
}
/*
Scalping Strategy Rules

📌 Entry Conditions (BUY)
Fast MA (5) crosses above Medium MA (13).
Medium MA (13) crosses above Slow MA (50).
RSI is above 30 and trending upwards (confirming momentum).
Place Buy Order at the next candle open.

📌 Entry Conditions (SELL)
Fast MA (5) crosses below Medium MA (13).
Medium MA (13) crosses below Slow MA (50).
RSI is below 70 and trending downwards.
Place Sell Order at the next candle open.
*/
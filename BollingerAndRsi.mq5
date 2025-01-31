//+------------------------------------------------------------------+
//|                                              BollingerAndRsi.mq5 |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include "Modules/Signal.mqh";
#include "Modules/RiskManagement.mqh";
#include "Modules/TradeExecution.mqh";
#include "Modules/Utils.mqh";
#include "Modules/ChartComment.mqh";

// Global instance of the TradeExecution class
TradeExecution tradeExec;
ChartComment chartComment;

input double BBDeviation = 2;
input int    BBPeriod = 20;

input double LOTSize = 0.01;
input int STOPLoss = 10;
input int TAKEProfit = 20;

input int RSIPeriod = 14;            // RSI period
input int RSIBuyLevel = 70;      // RSI level for buy
input int RSISellLevel = 30;     // RSI level for sell

input int RISKPercentage = 2;

datetime lastBarTime = 0; 
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

   //--- Check for signals
   datetime currentBarTime = iTime(_Symbol, PERIOD_CURRENT, 0); //--- Get the time of the current bar.
   if (currentBarTime != lastBarTime) { //--- Ensure processing happens only once per bar.
      lastBarTime = currentBarTime; //--- Update the last processed bar time.
      
      string bbSignal = BollingerBandSignal(BBPeriod,BBDeviation);
      string rsiSignal = RsiSignal(RSIPeriod,RSIBuyLevel,RSISellLevel);
      // Example: Display real-time dynamic information
       string messages[];
       ArrayResize(messages, 5);
       messages[0] = "Symbol: " + _Symbol;
       messages[1] = "Bid: " + DoubleToString(SymbolInfoDouble(_Symbol, SYMBOL_BID), 5);
       messages[2] = "Ask: " + DoubleToString(SymbolInfoDouble(_Symbol, SYMBOL_ASK), 5);
       messages[3] = "BBSignal Signal: " + bbSignal;
       messages[4] = "Rsi Signal: " + rsiSignal;
       
       chartComment.Show("Market Information", messages, ArraySize(messages));
       double dynamicLotSize = CalculateLotSize(RISKPercentage,STOPLoss);
      if (
         
            //(bbSignal==rsiSignal)&&(bbSignal=="BUY")
            bbSignal=="BUY"
         
      ) { //--- Check for RSI crossing below 30 (oversold signal).
         Print("BUY SIGNAL"); //--- Log a BUY signal.
         tradeExec.OpenTrade(ORDER_TYPE_BUY,dynamicLotSize,STOPLoss,TAKEProfit);
         
         
      } else if (
         //(bbSignal==rsiSignal)&&(bbSignal=="SELL")
         bbSignal=="SELL"
      ) { //--- Check for RSI crossing above 70 (overbought signal).
         Print("SELL SIGNAL"); //--- Log a SELL signal.
         tradeExec.OpenTrade(ORDER_TYPE_SELL,dynamicLotSize,STOPLoss,TAKEProfit);
      }
   }
   
  }
//+------------------------------------------------------------------+

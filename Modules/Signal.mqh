#ifndef SIGNALS_MQH
#define SIGNALS_MQH
#include "Signals/EmaCrossoverSignal.mqh";
#include "Signals/RsiSignal.mqh";
#include "Signals/EmaSignal.mqh";
#include "Signals/BollingerBandSignal.mqh";
#include "Signals/BollingerTouchSignal.mqh";
/*
int GetTradeSignal()
{
    
   // Handle creation for indicators
    int handleFast = iMA(Symbol(), Period(), EMA_Fast_Period, 0, MODE_EMA, PRICE_CLOSE);
    int handleSlow = iMA(Symbol(), Period(), EMA_Slow_Period, 0, MODE_EMA, PRICE_CLOSE);
    int handleVerySlow = iMA(Symbol(), Period(), EMA_Very_Slow_Period, 0, MODE_EMA, PRICE_CLOSE);
    int handleRSI = iRSI(Symbol(), Period(), RSI_Period, PRICE_CLOSE);

    // Arrays to hold indicator values
    double fast[], slow[], verySlow[], rsi[];

    // Copy the latest values
    CopyBuffer(handleFast, 0, 0, 1, fast) ;
        CopyBuffer(handleSlow, 0, 0, 1, slow); 
        CopyBuffer(handleVerySlow, 0, 0, 1, verySlow) ;
        CopyBuffer(handleRSI, 0, 0, 1, rsi) ;

    // Assigning values
    EMA_Fast = fast[0];
    EMA_Slow = slow[0];
    EMA_Very_Slow = verySlow[0];
    RSI_Value = rsi[0];

    //Print("EMA Fast: ", EMA_Fast, " EMA Slow: ", EMA_Slow, " EMA 200: ", EMA_Very_Slow, " RSI: ", RSI_Value);
    double priceClose = iClose(Symbol(), Period(), 0);
    

    if (((EMA_Fast > EMA_Slow && RSI_Value > RSI_Buy_Level && priceClose > EMA_Very_Slow)) && PositionsTotal() == 0)
    {
      //buy
       return 1;
    }

    if ((EMA_Fast < EMA_Slow && RSI_Value < RSI_Sell_Level && priceClose < EMA_Very_Slow) && PositionsTotal() == 0)
    {
        //Print("Sell signal");
        //sell
        return -1;
    }
    return 0;

}
*/
#endif
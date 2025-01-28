#ifndef RSISIGNAL_MQH
#define RSISIGNAL_MQH

string RsiSignal(int rsiPeriod,int rsiBuyLevel,int rsiSellLevel){
   //create an array for several prices
   double rsiArray[];
   
   // Handle creation for indicators( defind the property of moving average)
    int handleRSI = iRSI(Symbol(), Period(), rsiPeriod, PRICE_CLOSE);
    
   // sort the price array from the current candle downwards
   ArraySetAsSeries(rsiArray,true);
   
   //put the value to array
   CopyBuffer(handleRSI,0,0,3,rsiArray);
   
   //check if the fast(20) moving MA is above the slow(50) moving MA
   if(rsiArray[0] > rsiBuyLevel)
   {
      //Comment("BUY");
      return "BUY";
   }
   if(rsiArray[0] < rsiSellLevel){
      //Comment("SELL");
      return "SELL";
   }
   return "NoTrade";
   
}

#endif
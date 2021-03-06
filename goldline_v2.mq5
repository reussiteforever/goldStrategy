#property copyright "Abdel-Khafid ATOKOU"
#property link      "https://www.mql5.com"
#property version   "1.00"
#include<Trade\Trade.mqh>

/*
   THIS ROBOT IS MADE FOR VOLATILITY 75 INDICE
   THE STRATEGY IS BASED ON STOCHASTIC, MOMENTUM
   16-03-2021 : STRATEGY NOT PROFITABLE
*/

//Create an instance of CTrade
CTrade trade;

 
int OnInit()
  {
   Print("robot démarré");
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {

   
  }

void OnTick(){
 Print("new tick !");
   //We create an empty string for the signal
   string signal="";
   
   // We calculate the ask price
   double ask = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK), _Digits);
   
   // We calculate the bid price
   double bid = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID), _Digits);
   
   //We create an array for the K-Line & the D-Line
   double KArray[];
   double DArray[];
   
   //Momentum ARRAY
   double momentArray[];
   
   //Get the account balance
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   
   //Get the account equity
   double equity = AccountInfoDouble(ACCOUNT_EQUITY);
   
   //sort the array from the current candle downwards
   ArraySetAsSeries(KArray, true);
   ArraySetAsSeries(DArray, true);
   
   //Defined EA, current candle, 3 candles, save the result
   int stochasticDefinition = iStochastic(_Symbol, _Period, 14, 3, 3, MODE_LWMA, STO_CLOSECLOSE);
   
   // definition of momentum
   int momentDefinition = iMomentum(_Symbol, _Period, 14, PRICE_CLOSE);
   
   // We fill the arrays with price data
   CopyBuffer(stochasticDefinition,0,0,3,KArray);
   CopyBuffer(stochasticDefinition,1,0,3,DArray);
   CopyBuffer(momentDefinition,2,0,3,momentArray);
   
   // We calculate the value of the current candle
   double KValue0 = KArray[0];
   double DValue0 = DArray[0];
   
   // We calculate the value of the last candle
   double KValue1 = KArray[1];
   double DValue1 = DArray[1];
   
   
   double KValue2 = KArray[2];
   double DValue2 = DArray[2];
   
   // BUY SIGNAL
   if(KValue1 > DValue1){
      signal = "buy";
      //CloseAllSellPositions();
   }
   
   // SELL SIGNAL
   if(KValue1 < DValue1){
      signal = "sell";
      //CloseAllBuyPositions();
   }

   if(signal =="buy" && PositionsTotal()<1)
     {
         for(int i=0;i<2;i++)
           {
            trade.Buy(0.001,NULL,ask,(ask-1000),(ask+2000),NULL);
           }
            
         
         CloseAllSellPositions();
     }else if(signal=="sell" && PositionsTotal()<1)
             {
               for(int i=0;i<2;i++)
                 {
                  trade.Sell(0.001,NULL,bid,(bid+1000),(bid-2000),NULL);
                 }
                  
               
               CloseAllBuyPositions();
             }
       
 
   // Create a chart output
   Comment("The current signal is =",signal);
}

  void CloseAllBuyPositions() {
   for(int i = PositionsTotal()-1; i>=0; i--){
      string currencyPair = PositionGetSymbol(i); //identify the pair
      //Get the position type
      long  positionType = PositionGetInteger(POSITION_TYPE);
       
      //get the ticket number for the current position
      ulong ticket = PositionGetTicket(i);
      
      //if symbol on charts equals position symbol
      if(Symbol() == currencyPair){
         //if position type is buy
         if(positionType == POSITION_TYPE_BUY) {
            trade.PositionClose(ticket);
         }         
      }
   }
  }
  
  
  void CloseAllSellPositions() {
   for(int i = PositionsTotal()-1; i>=0; i--){
      string currencyPair = PositionGetSymbol(i); //identify the pair
      //Get the position type
       long positionType = PositionGetInteger(POSITION_TYPE);
       
      //get the ticket number for the current position
      ulong ticket = PositionGetTicket(i);
      
      //if symbol on charts equals position symbol
      if(Symbol() == currencyPair){
         //if position type is buy
         if(positionType == POSITION_TYPE_SELL) {
            trade.PositionClose(ticket);
         }         
      }
   }
  }
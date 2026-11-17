
#include <Trade/Trade.mqh>

CTrade trade;

input double LotSize = 0.01;
input int StopLossPoints = 500;
input int TakeProfitPoints = 1000;
input int FastEMA = 20;
input int SlowEMA = 50;

int fastHandle;
int slowHandle;

int OnInit()
{
   fastHandle = iMA(_Symbol, PERIOD_M5, FastEMA,
                    0, MODE_EMA, PRICE_CLOSE);

   slowHandle = iMA(_Symbol, PERIOD_M5, SlowEMA,
                    0, MODE_EMA, PRICE_CLOSE);

   if(fastHandle == INVALID_HANDLE ||
      slowHandle == INVALID_HANDLE)
      return INIT_FAILED;

   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   IndicatorRelease(fastHandle);
   IndicatorRelease(slowHandle);
}

void OnTick()
{
   if(_Symbol != "XAUUSD")
      return;

   if(PositionSelect(_Symbol))
      return;

   double fast[];
   double slow[];

   ArraySetAsSeries(fast, true);
   ArraySetAsSeries(slow, true);

   if(CopyBuffer(fastHandle, 0, 0, 3, fast) < 3)
      return;

   if(CopyBuffer(slowHandle, 0, 0, 3, slow) < 3)
      return;

   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);

   if(fast[2] <= slow[2] && fast[1] > slow[1])
   {
      trade.Buy(
         LotSize,
         _Symbol,
         0,
         ask - StopLossPoints * _Point,
         ask + TakeProfitPoints * _Point
      );
   }

   else if(fast[2] >= slow[2] && fast[1] < slow[1])
   {
      trade.Sell(
         LotSize,
         _Symbol,
         0,
         bid + StopLossPoints * _Point,
         bid - TakeProfitPoints * _Point
      );
   }
}

//+------------------------------------------------------------------+
//|                                                      secao-6.mq5 |
//|                                                     Thiago Alves |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Thiago Alves"
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//|                      43 - Variaveis Candle stick                                            |
//+------------------------------------------------------------------+
//Criar a vela sendo array e chamar o Copyrates passar os paramentros
MqlRates velas[];
//+------------------------------------------------------------------+
//|                          44 - Tick                                         |
//+------------------------------------------------------------------+
MqlTick tick;
//+------------------------------------------------------------------+
//|                         45 - Coment()                                         |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(5);
   
   CopyRates(_Symbol,_Period,0,3,velas);
   ArraySetAsSeries(velas,true);
//---Tick
SymbolInfoTick(_Symbol,tick);
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
int ind = 0;
string long_texto = "Preço de Abertura= "+DoubleToString(velas[ind].open)+"\n"+
                     "Preço de Fechamento= "+DoubleToString(velas[ind].close)+"\n"+
                     "Preço de Maxima= "+DoubleToString(velas[ind].high)+"\n"+
                     "Preço de Minima= "+DoubleToString(velas[ind].low)+"\n"+
                     "Ultima volume = "+DoubleToString(tick.last)+"\n"+
                     "Tempo = "+tick.time+"\n"+
                     "Vendedor = "+DoubleToString(tick.ask)+"\n"+
                     "Comprador = "+DoubleToString(tick.bid);
   Comment(long_texto);
   Alert(long_texto);
   //Coleta a vela na posição 0, ultima, preço de abertura. 
   //Print("Preço de Abertura ",velas[0].open);
   //Print("Preço de Fechamento ",velas[0].close);
   //Print("Preço de Maxima ",velas[0].high);
   //Print("Preço de Minima ",velas[0].low);
   //Print("------------------------------");
   //Print("Ultimo: ",tick.last);
   //Print("Tempo: ",tick.time);
   //Print("Vomule: ",tick.volume);
   //Print("Vendedor: ",tick.ask);
   //Print("Comprador: ",tick.bid);
   //Print("==============================")
  }
//+------------------------------------------------------------------+

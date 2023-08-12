//+------------------------------------------------------------------+
//|                                                      Secao 8.mq5 |
//|                                                     Thiago Alves |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Thiago Alves"
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//|                           49 - Indicadores                                       |
//+------------------------------------------------------------------+
//---Media Movel
int mm_Handle;
double mm_Buffer[];
//---IFR
int ifr_Handle;
double ifr_Buffer[];
//+------------------------------------------------------------------+
//|                     51 - Criar indicadores                                             |
//+------------------------------------------------------------------+
   int custom_Handle;
double custom_Buffer[];
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(5);
   
 //---Chamada para um indicador com teste de erro. Chamar o Buffert no Ontick
 mm_Handle = iMA(_Symbol,_Period,21,0,MODE_SMA,PRICE_CLOSE);
 ifr_Handle = iRSI(_Symbol,_Period,7,PRICE_CLOSE);
 //custom_Handle=iCustom(_Symbol,_Period,);  
 if(mm_Handle<0 ||ifr_Handle<0)
   {
    Alert("Erro de carregar indicador",GetLastError());
    return (-1);
   }
 ChartIndicatorAdd(0,0,mm_Handle);
 ChartIndicatorAdd(0,1,ifr_Handle);
//---
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
   CopyBuffer(mm_Handle,0,0,3,mm_Buffer);
   ArraySetAsSeries(mm_Buffer,true);
   CopyBuffer(ifr_Handle,0,0,3,ifr_Buffer);
   Print("Valor de MM = ",mm_Buffer[0]);
   Print("Valor de IFR = ",ifr_Buffer[0]);
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
    CopyBuffer(mm_Handle,0,0,3,mm_Buffer);
   ArraySetAsSeries(mm_Buffer,true);
   CopyBuffer(ifr_Handle,0,0,3,ifr_Buffer);
   Print("Valor de MM = ",mm_Buffer[0]);
   Print("Valor de IFR = ",ifr_Buffer[0]);
  }
//+------------------------------------------------------------------+

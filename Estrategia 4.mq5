//+------------------------------------------------------------------+
//|                                                 Estrategia 4.mq5 |
//|                                                     Thiago Alves |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Thiago Alves"
#property link      "https://www.mql5.com"
#property version   "1.00"
//---Bibliotecas
//+------------------------------------------------------------------+
//|                         Parametros de Input                                         |
//+------------------------------------------------------------------+
enum Estrategia_Entrada
  {
   APENAS_CRUZAMENTO_MM,
   APENAS_MACD,
   APENAS_BB,
   MACD_E_BB
  };
//---Os inputs
sinput string s0;//---Estrategia de entrada
input Estrategia_Entrada estrategia = APENAS_MACD;//---Estrategia de trader

sinput string s1;//---Bandas de Bollinger
input int periodo = 8; //Periodo da Banda
input double desvio = 2.0; //Desvio da Banda


sinput string s2; //MACD
input int   fast_ema_period=12;        // período da Média Móvel Rápida 
input int   slow_ema_period=26;        // período da Média Móvel Lenta 
input int   signal_period=9;           // período da diferença entre as médias móveis 
input ENUM_TIMEFRAMES      period=PERIOD_CURRENT;     // timeframe 

sinput string s3;//---Media Movel
input int mm_rapida_periodo = 12; //Periodo Rapida
input int mm_lenta_periodo = 32; //Periodo lenta
input ENUM_TIMEFRAMES mm_tempo_grafico = PERIOD_CURRENT; //Tempo do Grafico
input ENUM_MA_METHOD mm_metodo = MODE_EMA; //Metodo Exponenciaç Defaut


sinput string s4;//---Lotes negociaveis por vez, Lucro, redução de perda
input int num_lots = 1000;
input  double TK = 70; //Centavos R$0,70
input double SL = 70; //Prejuizo em Centavos R$1,35
input ENUM_APPLIED_PRICE preco = PRICE_CLOSE; //Preço aplicado

sinput string s5;//---Encerramento do Robô
input string hora_fechamento = "17:40"; //Fechamento das posição.
//+------------------------------------------------------------------+
//|                            Variaveis dos Indicadores             |
//+------------------------------------------------------------------+
//---Variaveis para o MACD

//--- buffers 
int MACD_Handle;
double MACDBuffer[]; 
double MACDSignalBuffer[]; 
//---Criar as varaives para banda de bollinger
int Bolling_Handle; 
double upperBand[];
double lowerBand[];
//---Variaveis para Medias Moveis
//Media Movel Lenta
int mm_lenta_Handle;
double mm_lenta_Buffer[];
//Media Movel Rapida
int mm_rapida_Handle;
double mm_rapida_Buffer[];
//+------------------------------------------------------------------+
//|                    Velas e Ticks                                 |
//+------------------------------------------------------------------+
int magic_num = 12345;
MqlRates velas[]; //Variavel Candle Stick
MqlTick tick; //Variavel Tick
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
    //Construindo os graficos
  MACD_Handle = iMACD(_Symbol,period,fast_ema_period,slow_ema_period,signal_period,preco);  
  //Bolling_Handle = iBands(_Symbol,PERIOD_CURRENT,20,0,2.0,preco);
  Bolling_Handle =iCustom(_Symbol,PERIOD_CURRENT,"Banda_Bollinger",periodo,0,desvio,preco);
   
   mm_lenta_Handle = iCustom(_Symbol,mm_tempo_grafico,"Media_Movel",32,0,MODE_SMA,preco,clrDarkOrange);
   //ObjectSetInteger(0,mm_lenta_Handle,OBJPROP_COLOR,clrLime);
   
   mm_rapida_Handle = iMA(_Symbol,mm_tempo_grafico,mm_rapida_periodo,0,mm_metodo,preco);
   PlotIndexSetInteger(0,PLOT_LINE_COLOR,0,clrAzure);  
  
   //Validar!
   if(Bolling_Handle<0 )
   {
    Alert("Erro de carregar indicador",GetLastError(),"!");
    return (-1);
   }
   //Colocando as velas
   CopyRates(_Symbol,_Period,0,4,velas);
   ArraySetAsSeries(velas,true);
//---Adicionando os graficos.
   ChartIndicatorAdd(0,0,Bolling_Handle);
   ChartIndicatorAdd(0,1,MACD_Handle);
   ChartIndicatorAdd(0,0,mm_lenta_Handle);
   ChartIndicatorAdd(0,0,mm_rapida_Handle);
  
 
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   IndicatorRelease(Bolling_Handle);
   IndicatorRelease(MACD_Handle);
   IndicatorRelease(mm_lenta_Handle);
   IndicatorRelease(mm_rapida_Handle);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---Mudar a cada novo tick e criando os Buffers
   CopyBuffer(Bolling_Handle,0,0,4,upperBand);
   CopyBuffer(Bolling_Handle,1,0,4,lowerBand);
   CopyBuffer(MACD_Handle,0,0,4,MACDBuffer);
   CopyBuffer(MACD_Handle,1,0,4,MACDSignalBuffer);
   CopyBuffer(mm_lenta_Handle,0,0,4,mm_lenta_Buffer);
   CopyBuffer(mm_rapida_Handle,0,0,4,mm_rapida_Buffer);
 
   
   CopyRates(_Symbol,_Period,0,4,velas);
   ArraySetAsSeries(velas,true);
   
   //---Ordenar os vetores de dados
   //ArraySetAsSeries(middleBand,true);
    ArraySetAsSeries(upperBand,true);
    ArraySetAsSeries(lowerBand,true);
    ArraySetAsSeries(MACDBuffer,true);
    ArraySetAsSeries(MACDSignalBuffer,true);
    ArraySetAsSeries(mm_lenta_Buffer,true);
   ArraySetAsSeries(mm_rapida_Buffer,true);  
   //---Alimenta o Tick;
   SymbolInfoTick(_Symbol,tick);
   double TK_movel = (0.05*tick.ask)*100;
   double SL_movel = (0.1*tick.ask)*100;
   //double fechamento = close();
   
   //---Logica para COMPRA
   //Compra Banda de Bollinger   
   bool compra_bollinger = lowerBand[0] > tick.ask;
   //Compra Cruzamento de medias Moveis. Se media movel rapida for maior que a lenta no ultimo perido e se ele tiver sido menor nos dois tick anteriores
   bool compra_mm_cros = mm_rapida_Buffer[0]> mm_lenta_Buffer[0] &&
   mm_rapida_Buffer[2]<mm_lenta_Buffer[2];
   //Compra MACD.
   bool compra_MACD = ((MACDBuffer[0] < MACDSignalBuffer[0]) && MACDBuffer[0]<0)&&MACDBuffer[2] < MACDSignalBuffer[2];
  
   //------Logica para VENDA DESCOBERTO  
   //Se a banda superior for menor que a vela no momento 1 então faz solicita a venda
   bool venda_bolliger = upperBand[0] <tick.bid;   
   //Se media movel lenta for maior que a rapida no ultimo perido e se ele tiver sido menor nos dois tick anteriores
   bool venda_mm_cros = mm_lenta_Buffer[0]> mm_rapida_Buffer[0] &&
   mm_lenta_Buffer[2]<mm_rapida_Buffer[2];
   //Venda MACD
   bool venda_MACD = MACDBuffer[0] > MACDSignalBuffer[0] && MACDBuffer[0]>0;
    //---Estrategias que o robô ira fazer
    bool Comprar = false; // Pode comprar?
    bool Vender  = false; // Pode vender?
    if(estrategia==APENAS_MACD)
      {
        Comprar=compra_MACD;
        Vender=venda_MACD;
      }
    else if(estrategia==APENAS_BB)
      {
      //Cruzamento das medias aquela que true para executar;
       Comprar=compra_bollinger;
       //Vender=venda_bolliger;
      }
     else if(estrategia==APENAS_CRUZAMENTO_MM)
            {
             Comprar=compra_mm_cros;
             //Vender=venda_stc;
            }
     
    
  //Returna se há novo tick ou candle stick 
    bool temosNovaVela = TemosNovaVela();
    //Toda vez que uma nova vela entrar
    if(temosNovaVela)
      {
       //Condição para Compra for true e o robô não esteja posicionado já negociando.
       if(Comprar &&PositionSelect(_Symbol)==false)
         {
         //Chama função linha vertical com nome compra e A função com Compra_acao
          LinhaVertical("Compra",velas[1].time,clrBlue);
          Compra_acao(SL_movel,TK_movel);;
         }
        //Condição para Vender for true e o robô não esteja posicionado já negociando.
       if(Vender &&PositionSelect(_Symbol)==false)
         {
         //Chama função linha vertical com nome compra e A função com Venda_acao descoberto ou
          LinhaVertical("Venda",velas[1].time,clrRed);
          Venda_acao();
         } 
      }
    //---Caso cheguemos no horario limite de negociações (17:40) e robô esteja posicionado.
    if(TimeToString(TimeCurrent(),TIME_MINUTES) == hora_fechamento && PositionSelect(_Symbol)==true)
        {
            Print("-----> Fim do Tempo Operacional: encerrar posições abertas!");
             
            if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
               {
                //Se a posição for compra chama a função fechar compra
                  //Fechar_compra();
                  LinhaVertical("Fechamento Compra",velas[0].time,clrBlueViolet);
               }
               //Se a posição for venda chama a função fechar venda
            else if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
               {
                  //Fechar_venda();
                  LinhaVertical("Fechamento Venda",velas[0].time,clrPink);
               }
        }
     
  }
   
    
  
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|         Função para auxiliar para vizualizar                                                         |
//+------------------------------------------------------------------+
void LinhaVertical(string nome, datetime dt, color cor=clrAquamarine)
{
   ObjectDelete(0,nome);
   ObjectCreate(0,nome,OBJ_VLINE,0,dt,0);
   ObjectSetInteger(0,nome,OBJPROP_COLOR,cor);
}
//+------------------------------------------------------------------+
//|                     Função de Compra                                             |
//+------------------------------------------------------------------+
   void Compra_acao(double Stop=60, double Profit=60)
   {
      MqlTradeRequest requisicao;
      MqlTradeResult  resposta;
      
      ZeroMemory(requisicao);
      ZeroMemory(resposta);
      
      //---Caracteristica da Ordem
      requisicao.action =TRADE_ACTION_DEAL; //Excuta a ordem a mercado.
      requisicao.magic = magic_num; //Numero Magico
      requisicao.symbol = _Symbol; //Ação
      requisicao.volume = num_lots; //Volume de 100 açoes
      requisicao.price = NormalizeDouble(tick.ask,_Digits); //Arredonda os decimais Ask pede do melhor vendedor
      requisicao.sl= NormalizeDouble(tick.ask-Stop*_Point,_Digits);//Valor de saída
      requisicao.tp=NormalizeDouble(tick.ask+Profit*_Point,_Digits); //Valor de entrada;
      requisicao.deviation = 0; //Sem desvio
      requisicao.type = ORDER_TYPE_BUY; //Compra
      requisicao.type_filling = ORDER_FILLING_FOK; //Se não estiver disponivel não faz a ordem de compra Fill or Kill
      
      //---
      bool ok=OrderSend(requisicao,resposta);
      //---
      if(ok&& ((resposta.retcode==10008)||(resposta.retcode==10009)) )
        {
         Print("Compra executada com sucesso!");
        }
        else
          {
           Print("Erro de compra: ",GetLastError(),"!");
           ResetLastError();
          }
      
      
   }

//+------------------------------------------------------------------+
//|                     Funçao de Venda                           |
//+------------------------------------------------------------------+
void Venda_acao()
{
     MqlTradeRequest requisicao;
      MqlTradeResult  resposta;
      
      ZeroMemory(requisicao);
      ZeroMemory(resposta);
      //---Caracteristica da Ordem
      requisicao.action =TRADE_ACTION_DEAL; //Excuta a ordem a mercado.
      requisicao.magic = magic_num; //Numero Magico
      requisicao.symbol = _Symbol; //Ação
      requisicao.volume = num_lots; //Volume de 100 açoes
      requisicao.price = NormalizeDouble(tick.bid,_Digits); //Arredonda os decimais Ask pede do melhor comprador
      requisicao.sl= NormalizeDouble(tick.bid+SL*_Point,_Digits);//Preço Stop Loss
      requisicao.tp=NormalizeDouble(tick.bid-TK*_Point,_Digits); //Alvo Ganho - Lucro;
      requisicao.deviation = 0; //Sem desvio
      requisicao.type = ORDER_TYPE_SELL; //Venda
      requisicao.type_filling = ORDER_FILLING_FOK; //Se não estiver disponivel não faz a ordem de compra Fill or Kill
      
      //---
      bool ok= OrderSend(requisicao,resposta);
      //---
      if(ok&& ((resposta.retcode==10008)||(resposta.retcode==10009)) )
        {
         Print("Compra executada com sucesso!");
        }
        else
          {
           Print("Erro na venda: ",GetLastError(),"!");
           ResetLastError();
          }
}
void Fechar_compra()
{
   MqlTradeRequest requisicao;
      MqlTradeResult  resposta;
      
      ZeroMemory(requisicao);
      ZeroMemory(resposta);
      //---Caracteristica da Ordem
      requisicao.action =TRADE_ACTION_DEAL; //Excuta a ordem a mercado.
      requisicao.magic = magic_num; //Numero Magico
      requisicao.symbol = _Symbol; //Ação
      requisicao.volume = num_lots; //Volume de 100 açoes
      requisicao.price = 0;
      requisicao.type = ORDER_TYPE_SELL; //Venda
      requisicao.type_filling = ORDER_FILLING_RETURN; //Se não estiver disponivel não faz a ordem de compra Fill or Kill
      
      //---
      bool ok=OrderSend(requisicao,resposta);
      //---
       if(ok&& ((resposta.retcode==10008)||(resposta.retcode==10009)) )
        {
         Print("Venda executada com sucesso!");
        }
        else
          {
           Print("Erro na venda: ",GetLastError(),"!");
           ResetLastError();
          }
}
//+------------------------------------------------------------------+
//|                   Função Fechar Venda                                               |
//+------------------------------------------------------------------+
void Fechar_venda()
   {
      MqlTradeRequest requisicao;
      MqlTradeResult  resposta;
      
      ZeroMemory(requisicao);
      ZeroMemory(resposta);
      
      //---Caracteristica da Ordem
      requisicao.action =TRADE_ACTION_DEAL; //Excuta a ordem a mercado.
      requisicao.magic = magic_num; //Numero Magico
      requisicao.symbol = _Symbol; //Ação
      requisicao.volume = num_lots; //Volume de 100 açoes
      requisicao.price = 0;
      requisicao.type = ORDER_TYPE_BUY; //Compra
      requisicao.type_filling = ORDER_FILLING_RETURN; //Se não estiver disponivel não faz a ordem de compra Fill or Kill
      
      //---
      bool ok=OrderSend(requisicao,resposta);
      //---
       if(ok&& ((resposta.retcode==10008)||(resposta.retcode==10009)) )
        {
         Print("Compra executada com sucesso!");
        }
        else
          {
           Print("Erro de compra: ",GetLastError(),"!");
           ResetLastError();
          }
      
      
   }
   
   //+------------------------------------------------------------------+
//| FUNÇÕES ÚTEIS                                                    |
//+------------------------------------------------------------------+
//--- Para Mudança de Candle
bool TemosNovaVela()
  {
//--- memoriza o tempo de abertura da ultima barra (vela) numa variável
   static datetime last_time=0;
//--- tempo atual
   datetime lastbar_time= (datetime) SeriesInfoInteger(Symbol(),Period(),SERIES_LASTBAR_DATE);

//--- se for a primeira chamada da função:
   if(last_time==0)
     {
      //--- atribuir valor temporal e sair
      last_time=lastbar_time;
      return(false);
     }

//--- se o tempo estiver diferente:
   if(last_time!=lastbar_time)
     {
      //--- memorizar esse tempo e retornar true
      last_time=lastbar_time;
      return(true);
     }
//--- se passarmos desta linha, então a barra não é nova; retornar false
   return(false);
  }   
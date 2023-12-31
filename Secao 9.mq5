//+------------------------------------------------------------------+
//|                                                      Secao 9.mq5 |
//|                                                     Thiago Alves |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Thiago Alves"
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//|                      54 -Criando o Robô MM e IRF                                             |
//+------------------------------------------------------------------+
//---Estrategia de entrada
enum Estrategia_Entrada
  {
   APENAS_MM,
   APENAS_IFR,
   MM_E_IFR,
  };
//---Os inputs
sinput string s0;//---Estrategia de entrada
input Estrategia_Entrada estrategia = APENAS_MM;//---Estrategia de trader

sinput string s1;//---Media Movel
input int mm_rapida_periodo = 12; //Periodo Rapida
input int mm_lenta_periodo = 32; //Periodo lenta
input ENUM_TIMEFRAMES mm_tempo_grafico = PERIOD_CURRENT; //Tempo do Grafico
input ENUM_MA_METHOD mm_metodo = MODE_EMA; //Metodo Exponenciaç Defaut
input ENUM_APPLIED_PRICE mm_preco = PRICE_CLOSE; //Preço aplicado

sinput string s2;//---IFR
input int ifr_periodo = 5; //Periodo Rapida
input ENUM_TIMEFRAMES ifr_tempo_grafico = PERIOD_CURRENT; //Tempo do Grafico
input ENUM_APPLIED_PRICE ifr_preco = PRICE_CLOSE; //Preço aplicado
input int ifr_sobrecompra = 80; //Nivel de SobreCompra;
input int ifr_sobrevenda = 20; //Nivel de SobreCompra;



sinput string s3;//---Lotes negociaveis por vez, Lucro, redução de perda
input int num_lots = 100;
input  double TK = 60; //Centavos R$0,60
input double SL = 30; //Prejuizo em Centavos R$0,30

sinput string s4;//---Encerramento do Robô
input string hora_fechamento = "17:40"; //Fechamento das posição.
//+------------------------------------------------------------------+
//|                            Variaveis dos Indicadores             |
//+------------------------------------------------------------------+
//Media Movel Lenta
int mm_lenta_Handle;
double mm_lenta_Buffer[];
//Media Movel Rapida
int mm_rapida_Handle;
double mm_rapida_Buffer[];
//---IFR
int ifr_Handle;
double ifr_Buffer[];
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
//--- create timer
   EventSetTimer(60);
   //Construindo os graficos
   mm_lenta_Handle = iMA(_Symbol,mm_tempo_grafico,mm_lenta_periodo,0,mm_metodo,mm_preco);
   
   mm_rapida_Handle = iMA(_Symbol,mm_tempo_grafico,mm_rapida_periodo,0,mm_metodo,mm_preco);
   ifr_Handle = iRSI(_Symbol,ifr_tempo_grafico,ifr_periodo,ifr_preco);
   //Validar!
   if(mm_lenta_Handle<0 ||ifr_Handle<0||mm_rapida_Handle<0)
   {
    Alert("Erro de carregar indicador",GetLastError(),"!");
    return (-1);
   }
   //Colocando as velas
   CopyRates(_Symbol,_Period,0,4,velas);
   ArraySetAsSeries(velas,true);
//---Adicionando os graficos.
ChartIndicatorAdd(0,0,mm_lenta_Handle);
 ChartIndicatorAdd(0,0,mm_rapida_Handle);
 ChartIndicatorAdd(0,1,ifr_Handle);

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
  IndicatorRelease(mm_lenta_Handle);
  IndicatorRelease(mm_rapida_Handle);
  IndicatorRelease(ifr_Handle);
//--- destroy timer
   //EventKillTimer();
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   //LinhaVertical("L1",tick.time,clrAquamarine);
//---Carrega o buffer ao vetores
   
   CopyBuffer(mm_lenta_Handle,0,0,4,mm_lenta_Buffer);
   CopyBuffer(mm_rapida_Handle,0,0,4,mm_rapida_Buffer);
    CopyBuffer(ifr_Handle,0,0,4,ifr_Buffer);
   
   //---
   CopyRates(_Symbol,_Period,0,4,velas);
   ArraySetAsSeries(velas,true);
   
   //---Ordenar os vetores de dados
   ArraySetAsSeries(mm_lenta_Buffer,true);
   ArraySetAsSeries(mm_rapida_Buffer,true);
    ArraySetAsSeries(ifr_Buffer,true);
   //---Alimenta o Tick;
   SymbolInfoTick(_Symbol,tick);
   //---Logica para COMPRA
   //Se media movel rapida for maior que a lenta no ultimo perido e se ele tiver sido menor nos dois tick anteriores
   bool compra_mm_cros = mm_rapida_Buffer[0]> mm_lenta_Buffer[0] &&
   mm_rapida_Buffer[2]<mm_lenta_Buffer[2];
   //Se ifr no ultimo estante for igual a area de Sobrevenda da ação.
   bool compra_ifr = ifr_Buffer[0]<=ifr_sobrevenda;
   
   //------Logica para VENDA   
   //Se media movel lenta for maior que a rapida no ultimo perido e se ele tiver sido menor nos dois tick anteriores
   bool venda_mm_cros = mm_lenta_Buffer[0]> mm_rapida_Buffer[0] &&
   mm_lenta_Buffer[2]<mm_rapida_Buffer[2];
   //Se ifr no ultimo estante for menor ou igual a area de Sobrecompra da ação.
   bool venda_ifr = ifr_Buffer[0]>=ifr_sobrecompra;
   
   //---Estrategias que o robô ira fazer
    bool Comprar = false; // Pode comprar?
    bool Vender  = false; // Pode vender?
    //Estrategia que usuario escolheu no input
    if(estrategia==APENAS_MM)
      {
      //Cruzamento das medias aquela que true para executar;
       Comprar=compra_mm_cros;
       Vender=venda_mm_cros;
      }
      else if(estrategia==APENAS_IFR)
             {
      //Ultrapassar limite do IR fica igual a true para executar;
       Comprar=compra_ifr;
       Vender=venda_ifr;
             }
    else
      {
      //As duas condiçoes serem atendidas para ser true para venda ou compra.
       Comprar=compra_ifr && compra_mm_cros;
       Vender=venda_ifr && venda_mm_cros;
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
          Compra_acao();
         }
        //Condição para Vender for true e o robô não esteja posicionado já negociando.
       if(Vender &&PositionSelect(_Symbol)==false)
         {
         //Chama função linha vertical com nome compra e A função com Compra_acao
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
                  Fechar_compra();
                  LinhaVertical("Fechamento Compra",velas[1].time,clrBlueViolet);
               }
               //Se a posição for venda chama a função fechar venda
            else if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
               {
                  Fechar_venda();
                  LinhaVertical("Fechamento Venda",velas[1].time,clrPink);
               }
        }
     
  }
  
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   
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
   void Compra_acao()
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
      requisicao.sl= NormalizeDouble(tick.ask-SL*_Point,_Digits);//Valor de saída
      requisicao.tp=NormalizeDouble(tick.ask+TK*_Point,_Digits); //Valor de entrada;
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
   
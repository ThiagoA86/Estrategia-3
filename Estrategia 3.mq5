//+------------------------------------------------------------------+
//|                                                     laytou 3.mq5 |
//|                                                     Thiago Alves |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Thiago Alves"
#property link      "https://github.com/ThiagoA86"
#property version   "1.00"
//---Bibliotecas
//+------------------------------------------------------------------+
//|                         Parametros de Input                                         |
//+------------------------------------------------------------------+
enum Estrategia_Entrada
  {
   APENAS_BB,
   APENAS_ESTOCASTICO,
   BB_OU_ESTOCASTICO
  };
//---Os inputs
sinput string s0;//---Estrategia de entrada
input Estrategia_Entrada estrategia = APENAS_BB;//---Estrategia de trader

sinput string s1;//---Bandas de Bollinger
input int periodo = 20; //Periodo da Banda
input double deviation = 2.0; //Desvio da Banda
input ENUM_APPLIED_PRICE bb_preco = PRICE_CLOSE; //Preço aplicado

sinput string s2; //Estocastico
input int                  Kperiod=8;                 // o período K ( o número de barras para cálculo) 
input int                  Dperiod=3;                 // o período D (o período da suavização primária) 
input int                  slowing=3;                 // período final da suavização 
input ENUM_MA_METHOD       ma_method=MODE_EMA;        // tipo de suavização MME defaut
input int Stochastic_sobrecompra = 80; //Nivel de SobreCompra;
input int Stochastic_sobrevenda = 20; //Nivel de SobreVenda; 


sinput string s3;//---Lotes negociaveis por vez, Lucro, redução de perda
input int num_lots = 1000;
input  double TK = 60; //Centavos R$0,60
input double SL = 30; //Prejuizo em Centavos R$0,30



sinput string s4;//---Encerramento do Robô
input string hora_fechamento = "17:40"; //Fechamento das posição.
//+------------------------------------------------------------------+
//|                            Variaveis dos Indicadores             |
//+------------------------------------------------------------------+

//---Criar as varaives para banda de bollinger
int Bolling_Handle; 
double middleBand[];
double upperBand[];
double lowerBand[];
//---Variaveis para estocastico
int Stochastic_Handle;
double Stochastic_Buffer[]; 
double Signal_Buffer[]; 
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
    
  Bolling_Handle = iBands(_Symbol,PERIOD_CURRENT,20,0,2.0,bb_preco);
    // Definir a cor da linha inferior da Banda de Bollinger como azul
     ObjectSetInteger(0,"Bolling_Handle",OBJPROP_WIDTH,3);
     
  Stochastic_Handle = iStochastic(_Symbol,PERIOD_CURRENT,Kperiod,Dperiod,slowing,ma_method,STO_LOWHIGH);
   
  //SetLineColor(2, clrBlue); // Linha inferior
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
   ChartIndicatorAdd(0,1,Stochastic_Handle);
  
 
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
   IndicatorRelease(Stochastic_Handle);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---Mudar a cada novo tick e criando os Buffers
   CopyBuffer(Bolling_Handle,0,0,4,middleBand);
   CopyBuffer(Bolling_Handle,1,0,4,upperBand);
   CopyBuffer(Bolling_Handle,2,0,4,lowerBand);
   
   CopyBuffer(Stochastic_Handle,0,0,4,Stochastic_Buffer);
   CopyBuffer(Stochastic_Handle,1,0,4,Signal_Buffer);     
   
   CopyRates(_Symbol,_Period,0,4,velas);
   ArraySetAsSeries(velas,true);
   
   //---Ordenar os vetores de dados
   ArraySetAsSeries(middleBand,true);
    ArraySetAsSeries(upperBand,true);
    ArraySetAsSeries(lowerBand,true);
    ArraySetAsSeries(Stochastic_Buffer,true);
    ArraySetAsSeries(Signal_Buffer,true);   
   //---Alimenta o Tick;
   SymbolInfoTick(_Symbol,tick);
   double TK_movel = (0.05*tick.ask)*100;
   double SL_movel = (0.1*tick.ask)*100;
   //double fechamento = close();
   
   //---Logica para COMPRA
   //Compra Banda de Bollinger   
   bool compra_bollinger = lowerBand[0] > tick.ask;
   //Compra Estocastico quando true haver o cruzamento da linha principal e ela estiver abaixo da sobrevenda
    bool compra_stc = (Stochastic_Buffer[0]> Signal_Buffer[0] &&
   Stochastic_Buffer[2]<Signal_Buffer[2]) && (Stochastic_Buffer[0]<Stochastic_sobrevenda);
   //------Logica para VENDA   
   //Se a banda superior for menor que a vela no momento 1 então faz solicita a venda
   bool venda_bolliger = upperBand[0] <tick.bid;
   //Compra Estocastico quando true se haver o cruzamento da linha principal com a de sinal e ela estiver acima da sobrecompra
    bool venda_stc = (Stochastic_Buffer[0]< Signal_Buffer[0] &&
   Stochastic_Buffer[2]>Signal_Buffer[2]) && (Stochastic_Buffer[0]>Stochastic_sobrecompra);
    //---Estrategias que o robô ira fazer
    bool Comprar = false; // Pode comprar?
    bool Vender  = false; // Pode vender?
    if(estrategia==APENAS_BB)
      {
      //Cruzamento das medias aquela que true para executar;
       Comprar=compra_bollinger;
       //Vender=venda_bolliger;
      }
     else if(estrategia==APENAS_ESTOCASTICO)
            {
             Comprar=compra_stc;
             //Vender=venda_stc;
            }
     else
       {
        Comprar=compra_bollinger||compra_stc;
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
          Compra_acao(SL_movel,TK_movel);
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
   
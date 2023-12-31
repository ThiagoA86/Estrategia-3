//+------------------------------------------------------------------+
//|                                                     35-input.mq5 |
//|                                                     Thiago Alves |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Thiago Alves"
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//|              35 - INPUT (Parâmetros)                                                    |
//+------------------------------------------------------------------+

//---Paramentros de indicador que será requisitada
enum ESTACAO_ANO
  {
   Verao=1,
   Outuno=2,
   Inverno=3,
   Primavera=4,
  };
input int periodos=20; //Numero de periodos de interação
input string comentarios="";
input ESTACAO_ANO estacao = Inverno;//Estação
//+------------------------------------------------------------------+
//|                           36 Função MQL5                                       |
//+------------------------------------------------------------------+

void minha_func(double a, double b)
{
   double soma = a+b;
   Print("Soma de a + b = ",soma);
}
double minha_func2(double c, double d)
{
   double div = c/d;
   return div;
}
//+------------------------------------------------------------------+
//|              38- Variaveis Predifinidas                                                   |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                     40 - Operadores Condionais                                             |
//+------------------------------------------------------------------+
//Condicionais
//int A = 4;
//int B = 4;
//int C = 8;
//if(A==B && A+B==C)
//  {
//   Print("OK!");
//      else if(condition)
//             {
//              
//             }
//  }
//+------------------------------------------------------------------+
//|                     41 - Operadores Ternario                                        |
//+------------------------------------------------------------------+
//(condicional)?(alternativa verdadeira):(alternativa falsa)
   
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(5);
   //38 Variaveis Predifinidas
   Print("Nome da Ação: ",_Symbol);
   Print("Periodo: ",_Period);
   Print("Pontos: ",_Point);
   Print("Digitos: ",_Digits);
//---
//Condicionais
int A = 4;
int B = 4;
int C = 8;
if(A==B && A+B==C)
  {
   Print("OK!");
  }
 bool cond = true;
 bool resp = cond?true:false;
 Print(resp);
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
   //minha_func(7.8,9.2);
   //Print("Meu retorno ",minha_func2(6,3));
  }
//+------------------------------------------------------------------+

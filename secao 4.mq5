//+------------------------------------------------------------------+
//|                                                   primeiroEA.mq5 |
//|                                                     Thiago Alves |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Thiago Alves"
#property link      "https://www.mql5.com"
#property version   "1.00"
//---Bibliotecas
//#include <Canvas/FlameCanvas.mqh>
//---Chamar uma classe
//CCanvas c;
//Comentarios faz //
/*
Comentarios Longo de mais de uma linha
*/
//---Variavies inteiras
int var_1;
int var_2 = 70;
ushort var_3 = 567;
uint var_4 = 98;
uint var_5 = -24;
//---Decimais
double var_6 = 1.81;
float a = 1.5;
float b = 0.5;
double c = a/b;
//---String
string s_a="Olá Mundo.";
string s_b=" Concatenção";
string s_c = s_a+s_b;
//--- Constantes
#define X 3.48
#define AVISO "OLÀ MUNDO"
//--- ENUM cria varaiveis inteiras dentro de outra variavel.
enum NOME_CASA
  {
   Thiago=1,
   Alves=2,
   Pereira=3,
  };


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+


int OnInit()
  {
//--- create timer A cada 2 segundo
   EventSetTimer(5);
   Print(s_c);
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
    Print("Robô desligado");
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//Parte Principal do EA 
   //Print("Estamos no OnTick");
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
int k = 0;
void OnTimer()
  {
//---
  //Print("Passou 2 seg",k++);
  //Print("Var 2 ", var_2,"Var 5 ",var_5);
//  bool resp;
//  resp = var_2 < var_3;
//  
//  
//  Print("Resposta do teste ",resp); 
//  }
//---DateTime variavel = D'ano.mes.dia hh:mm:ss' 
//datetime data = D'2023.07.14 22:12';
//datetime data2;
//datetime data3 =D'2023.07.14';
//
//Print(data, ' ', data2,' ',data3);
//---Array 
int Array[3];
Array[0]=77;
Array[1]=8;
Array[2]=6;
double Arrat2[2]={3.3,28.5};
//---Laços de Repetição
for(int i=0;i<ArraySize(Array);i++)
  {
   Print(Array[i]);
  }
//Print(Array);
//Print(Arrat2);
NOME_CASA nome;
nome = Pereira;
Print("Nome: ",nome);
}
//+------------------------------------------------------------------+

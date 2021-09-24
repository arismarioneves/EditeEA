//+------------------------------------------------------------------+
//|                                                        Edite.mq5 |
//|                                 Copyright 2021, Arismário Neves. |
//|                                           arismarioneves@hotmail |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Arismário Neves."
#property link      "http://arismario.tk"

#property description "Edite é um robô customizado para day trade.\n"
#property description "@arismarioneves – arismarioneves@hotmail.com"

#define EA "Edite"
#define VERSION "1.0"

#define MQL5STORE false

#property version VERSION

//Arismário Neves
//Versão 1.0

//+------------------------------------------------------------------+
//| Include                                                          |
//+------------------------------------------------------------------+
//--- Painel
#include "Painel.mqh"
//--- Fontes
#include "Fonts.mqh"
//--- TraderPad
#include "TraderPad.mqh"

#include <Trade\PositionInfo.mqh>
#include <Trade\SymbolInfo.mqh>
#include <Trade\OrderInfo.mqh>
#include <Trade\Trade.mqh>

#include <Controls\Button.mqh>

//--- Keys IDs
#define KEY_I 73

//#resource "\\Experts\\"+EA+"\\System.ex5"
//+------------------------------------------------------------------+
//--- enums
enum ENUM_TIMEFRAMES_INDEX {
   CURRENT  = PERIOD_CURRENT, // Período atual [Current]
   M1    = PERIOD_M1,         // 1 minutos
   M5    = PERIOD_M5,         // 5 minutos
   M15   = PERIOD_M15,        // 15 minutos
   M30   = PERIOD_M30,        // 30 minutos
   H1    = PERIOD_H1,         // 1 hora
   H4    = PERIOD_H4,         // 4 horas
   D1    = PERIOD_D1,         // Diariamente [Daily]
   W1    = PERIOD_W1,         // Semanal [Weekly]
   MN1   = PERIOD_MN1         // Mensal [Monthly]
};
enum NUMBER_LIST {
   ZERO  = 0, // Não
   ONE   = 1, // 1
   TWO   = 2, // 2
   TREE  = 3, // 3
   FOUR  = 4, // 4
   FIVE  = 5  // 5
};
enum CHOOSE {
   SIM   = 1, // Sim
   NAO   = 0  // Não
};
enum ENUM_BAR {
   ATUAL = 0, // Atual
   NOVO  = 1  // Próximo
};
enum ENUM_OBJ_CORNER {
   CORNER_CHART_RIGHT_UPPER   = CORNER_RIGHT_UPPER,   // Canto superior direito do gráfico
   CORNER_CHART_LEFT_LOWER    = CORNER_LEFT_LOWER     // Canto inferior esquerdo do gráfico
};
enum ENUM_BUTTON_CORNER {
   CORNER_BUTTON_LEFT_UPPER   = CORNER_LEFT_UPPER,    // Canto superior esquerdo do gráfico
   CORNER_BUTTON_RIGHT_UPPER  = CORNER_RIGHT_UPPER,   // Canto superior direito do gráfico
   CORNER_BUTTON_LEFT_LOWER   = CORNER_LEFT_LOWER,    // Canto inferior esquerdo do gráfico
   CORNER_BUTTON_RIGHT_LOWER  = CORNER_RIGHT_LOWER    // Canto inferior direito do gráfico
};
enum ENUM_WEEK_BEGIN {
   BEGINNING_ON_MONDAY, // Segunda
   BEGINNING_ON_SUNDAY  // Domingo
};
//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
//--- inputs for expert
sinput   string   ExpertTitle          = EA;       // Robô
sinput   string   AcessCode            = "";       // Código de acesso

//--- inputs parameters
input group "CONTRATOS";
input    double   InpLots              = 1;        // Quantidade de contratos

input group "GANHO E PERDA";
input    ushort   InpTakeProfit        = 60;       // Ganho máximo [Take Profit]
input    ushort   InpStopLoss          = 90;       // Perda máxima [Stop Loss]

input group "REVERSÃO";
input    CHOOSE   TradeReverse         = NAO;      // Usar Reversão em caso de perda
input    double   InpLotsReverse       = 2;        // Contratos na Reversão

input group "TRADER PAD";
input    double   PadLots              = 1;        // Contratos
input    ushort   PadTakeProfit        = 50;       // Ganho [Gain]
input    ushort   PadStopLoss          = 50;       // Perda [Loss]

input group "LÓGICA";
input    ENUM_TIMEFRAMES_INDEX InpTimeFrame = M5;  // Tempo gráfico [Time frame]

input    int      InpShortMA_Period    = 10;       // MA I: Período curto
input    ENUM_MA_METHOD       InpShortMA_Method    = MODE_EMA;    // MA I: Método
input    int      InpFirst_MA_Shift    = 0;        // MA I: Deslocar
input    ENUM_APPLIED_PRICE   InpShortMA_Applied   = PRICE_CLOSE; // MA I: Aplicar

input    int      InpLongMA_Period     = 50;       // MA II: Período longo
input    ENUM_MA_METHOD       InpLongMA_Method     = MODE_SMA;    // MA II: Método
input    int      InpSecond_MA_Shift   = 0;        // MA II: Deslocar
input    ENUM_APPLIED_PRICE   InpLongMA_Applied    = PRICE_CLOSE; // MA II: Aplicar

input    ushort   InpMinCrossDistance  = 50;       // Distância mínima após cruzamento

input group "PARCIAL";
input    CHOOSE   HabilitaParcial      = SIM;      // Usar Parcial nas operações
input    double   PontosParcial        = 30;       // Pontos para ativar a Parcial
input    int      PorcentParcial       = 50;       // Porcentagem contratos na Parcial
input    CHOOSE   MoveStop             = SIM;      // Mover Stop Loss ao usar a Parcial
input    double   PontosMoveStop       = 30;       // Perda máxima do novo Stop Loss

input group "STOP MÓVEL";
input    ushort   InpTrailingStop      = 0;        // Stop Móvel [Trailing Stop]
input    ushort   InpTrailingStep      = 0;        // Trailing Step

input group "PERSONALIZAR";
input    double   MetaGain             = 0;        // Meta de ganhos no dia R$
input    double   MetaLoss             = 0;        // Máximo de perdas no dia R$
input    NUMBER_LIST MaxLoss           = ZERO;     // Máximo de perdas seguidas

input    double   CustoTrade           = 0.51;     // Custo médio contrato operado (0.00)

input    CHOOSE   OneTrade             = NAO;      // Operar apenas uma vez ao dia
input    CHOOSE   TradeAlways          = SIM;      // Operar com outras ordens abertas
input    CHOOSE   CloseOpposite        = SIM;      // Fechar ordem em caso de ordem oposta
input    CHOOSE   ClosePositions       = NAO;      // Fechar ordens ainda abertas (17h30)
input    CHOOSE   CheckMoney           = NAO;      // Verificar saldo antes da operação

input    CHOOSE   NewBar               = SIM;      // Operar apenas no início do candle
input    ENUM_BAR InpCurrentBar        = NOVO;     // Candle da operação

input    CHOOSE   Push                 = NAO;      // Ativar notificação Android ou iPhone
input    CHOOSE   Alerts               = NAO;      // Exibir alertas
input    CHOOSE   Prints               = SIM;      // Exibir mensagens/avisos

input    ulong    InpSlippage          = 10;       // Derrapagem [Slippage]
input    ulong    InpDevPts            = 10;       // Desvio permitido do preço

input    ulong    MagicNumber          = 587590;   // Número mágico [1-100000]

input group "HORÁRIO DE FUNCIONAMENTO";
input    CHOOSE   HourTrade            = SIM;      // Ativar horário de funcionamento
input    uchar    InpStartHour         = 9;        // Início operações [horas]
input    uchar    InpStartMinute       = 0;        // Início operações [minutos]
input    uchar    InpEndHour           = 16;       // Término operações [horas]
input    uchar    InpEndMinute         = 30;       // Término operações [minutos]

//--- input parameters button
ENUM_BUTTON_CORNER   ButtonPosition    = CORNER_BUTTON_RIGHT_LOWER;  // Posição do botão ON/OFF

//--- input parameters painel
ENUM_WEEK_BEGIN   InpWeekBegin         = BEGINNING_ON_SUNDAY;  // Dia de início da semana
uint              InpOffsetX           = 10;                   // Deslocamento horizontal do painel
uint              InpOffsetY           = 25;                   // Deslocamento vertical do painel

input group "CONFIGURAR EXIBIÇÃO";
input    ENUM_OBJ_CORNER   InpCorner               = CORNER_CHART_RIGHT_UPPER;      // Posição do painel
input    uchar             InpPanelTransparency    = 200;                           // Transparência do painel (48-255)
input    TYPE_FONTE        FontType                = Font5;                         // Fonte
input    color             InpPanelColorBG         = clrAliceBlue;                  // Cor do painel
input    color             InpPanelColorBD         = clrSilver;                     // Cor da borda do painel
input    color             InpPanelColorTX         = clrBlack;                      // Cor do texto no painel
input    color             InpPanelColorLoss       = clrRed;                        // Cor do texto da perda
input    color             InpPanelColorProfit     = clrGreen;                      // Cor do texto do lucro

//--- input parameters label
input    color             ColorTimeCandle         = clrOrangeRed;                  // Cor do tempo do candle
//+------------------------------------------------------------------+

// Em desenvolvimento...

//+------------------------------------------------------------------+
//| CheckMoneyForTrade                                               |
//+------------------------------------------------------------------+
bool CheckMoneyForTrade(string symb, double lots, ENUM_ORDER_TYPE type) {
//--- obtemos o preço de abertura
   MqlTick mqltick;
   SymbolInfoTick(symb, mqltick);
   double price = mqltick.ask;
   if(type == ORDER_TYPE_SELL)
      price = mqltick.bid;
//--- valores da margem necessária e livre
   double margin, free_margin = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
//--- chamamos a função de verificação
   if(!OrderCalcMargin(type, symb, lots, price, margin)) {
      //--- algo deu errado, informamos e retornamos false
      if(Prints)
         Print("Erro em ", __FUNCTION__, ". Código de erro: ", GetLastError());
      return(false);
   }
//--- se não houver fundos suficientes para realizar a operação
   if(margin > free_margin) {
      //--- informamos sobre o erro e retornamos false
      if(Prints)
         Print("Não há saldo suficiente para ", EnumToString(type), " ", InpLots, " " + symb + ". Código de erro: ", GetLastError(), ".");
      return(false);
   }
//--- a verificação foi realizada com sucesso
   return(true);
}
//+------------------------------------------------------------------+
//| Verifica a validez do volume da ordem                            |
//+------------------------------------------------------------------+
bool CheckVolumeValue(double volume, string & description) {
//--- valor mínimo permitido para operações de negociação
   double min_volume = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_MIN);
   if(volume < min_volume) {
      description = StringFormat("Volume inferior ao mínimo permitido SYMBOL_VOLUME_MIN=%.2f", min_volume);
      return(false);
   }
//--- volume máximo permitido para operações de negociação
   double max_volume = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_MAX);
   if(volume > max_volume) {
      description = StringFormat("Volume superior ao máximo permitido SYMBOL_VOLUME_MAX=%.2f", max_volume);
      return(false);
   }
//--- obtemos a gradação mínima do volume
   double volume_step = SymbolInfoDouble(Symbol(), SYMBOL_VOLUME_STEP);
   int ratio = (int)MathRound(volume / volume_step);
   if(MathAbs(ratio * volume_step - volume) > 0.0000001) {
      description = StringFormat("O volume não é múltiplo da gradação mínima SYMBOL_VOLUME_STEP=%.2f, volume mais próximo do válido é %.2f",
                                 volume_step, ratio * volume_step);
      return(false);
   }
   description = "Valor válido do volume";
   return(true);
}
//+------------------------------------------------------------------+
//| Verifica se um modo de preenchimento específico é permitido      |
//+------------------------------------------------------------------+
bool IsFillingTypeAllowed(string symbol, int fill_type) {
//--- Obtém o valor da propriedade que descreve os modos de preenchimento permitidos
   int filling = (int)SymbolInfoInteger(symbol, SYMBOL_FILLING_MODE);
//--- Retorna true, se o modo fill_type é permitido
   return((filling & fill_type) == fill_type);
}

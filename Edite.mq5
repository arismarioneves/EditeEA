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

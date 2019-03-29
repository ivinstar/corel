//+------------------------------------------------------------------+
//|                                                       Corell.mq4 |
//|                                              Copyright 2019, AM2 |
//|                                      http://www.forexsyatems.biz |
//|  28.03.2019 - выведены в пользовательские настройки внешнего вида кнопки
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, AM2"
#property link      "http://www.forexsyatems.biz"
#property version   "1.00"
#property strict

//--- Inputs
extern string Symb1      = "USDJPY";
extern string Symb2      = "USDMXN";
extern int Side1         = 0;        // 1-й символ 0-buy 1-sell
extern int Side2         = 1;        // 2-й символ 0-buy 1-sell
extern double Lot1       = 1;        // лот 1
extern double Lot2       = 1;        // лот 2
extern double Loss       = 10000;      // убыток
extern double Profit     = 1000;       // профит
extern int StopLoss      = 0;        // лось
extern int TakeProfit    = 0;        // язь
extern int Slip          = 30;       // реквот
extern int Magic         = 111;      // магик
extern string Com        = "Corel";  // комментарий

extern int ButtonX = 100; // Ориентирование по оси Х
extern int ButtonY = 30; // Ориентирование по оси Y
extern int ButtonCorner = 4; // Угол графика для привязки
extern string ButtonText = "Доливка"; // Текст кнопки
extern int ButtonWidth = 80; // Ширина кнопки
extern int ButtonHeight = 30; // Высота кнопки

string OpenAlertString = "";
string ErrorAlertString = "";
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   Comment("");
   PutButton("O",500,10,ButtonText);
//   PutButton("C",100,40,"Закрыть все");
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   Comment("");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PutButton(string name,int x,int y,string text)
  {
   ObjectCreate(0,name,OBJ_BUTTON,0,0,0);
//--- установим координаты кнопки
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,ButtonX);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,ButtonY);
//--- установим размер кнопки
   ObjectSetInteger(0,name,OBJPROP_XSIZE,ButtonWidth);
   ObjectSetInteger(0,name,OBJPROP_YSIZE,ButtonHeight);
//--- установим угол графика, относительно которого будут определяться координаты точки
   ObjectSetInteger(0,name,OBJPROP_CORNER,ButtonCorner);
//--- установим текст
   ObjectSetString(0,name,OBJPROP_TEXT,text);
//--- установим шрифт текста
   ObjectSetString(0,name,OBJPROP_FONT,"Arial");
//--- установим размер шрифта
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,12);
//--- установим цвет текста
   ObjectSetInteger(0,name,OBJPROP_COLOR,Black);
//--- установим цвет фона
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,clrBeige);
//--- установим цвет границы
   ObjectSetInteger(0,name,OBJPROP_BORDER_COLOR,Blue);
//--- скроем (true) или отобразим (false) имя графического объекта в списке объектов
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,false);
//--- установим приоритет на получение события нажатия мыши на графике
   ObjectSetInteger(0,name,OBJPROP_ZORDER,0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int PutOrder(string symb,int type,double price,double lot)
  {
   int r=0;
   string s = "";
   int dg=(int)SymbolInfoInteger(symb,SYMBOL_DIGITS);

   color clr=Green;
   double sl=0,tp=0,po=SymbolInfoDouble(symb,SYMBOL_POINT);

   if(type==1 || type==3 || type==5)
     {
      clr=Red;
      if(StopLoss>0) sl=NormalizeDouble(price+StopLoss*po,dg);
      if(TakeProfit>0) tp=NormalizeDouble(price-TakeProfit*po,dg);
     }

   if(type==0 || type==2 || type==4)
     {
      clr=Blue;
      if(StopLoss>0) sl=NormalizeDouble(price-StopLoss*po,dg);
      if(TakeProfit>0) tp=NormalizeDouble(price+TakeProfit*po,dg);
     }
   r=OrderSend(symb,type,lot,NormalizeDouble(price,dg),Slip,sl,tp,Com,Magic,0,clr);
   
   s = BuildTypeCase(type) + ", " + symb + "(" + lot  + "); ";
      if(r<0) {
         BuildError("open_order_error", s);
      } else {
         OpenAlertString += s;
      }
       
   return r;
  }
  
  
int BuildOpenAlert()  {
   Alert("Доливка " + OpenAlertString + " успешно выполнена");  
   OpenAlertString = "";
   return(0);
}  

int BuildError(string type, string s)  {
   Alert("Ошибка открытия " + s + ", код ошибки #" + GetLastError());  
   ErrorAlertString = "";
   return(0);
}  
  
string BuildTypeCase(int type)  {
   string r = "";
   switch(type) {
      case 0:
          r = "BUY"; break;
      case 1:
          r = "SELL"; break;       
   }  
   return r;
}   
  
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseAll()
  {
   bool cl;
   int dig=0;
   string symb="";
   double bid=0,ask=0;

   for(int i=OrdersTotal()-1;i>=0;i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderMagicNumber()==Magic)
           {
            if(OrderType()==0)
              {
               RefreshRates();
               symb=OrderSymbol();
               bid=MarketInfo(symb,MODE_BID);
               dig=(int)MarketInfo(symb,MODE_DIGITS);
               cl=OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(bid,dig),Slip,White);
              }
            if(OrderType()==1)
              {
               RefreshRates();
               symb=OrderSymbol();
               ask=MarketInfo(symb,MODE_ASK);
               dig=(int)MarketInfo(symb,MODE_DIGITS);
               cl=OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(ask,dig),Slip,White);
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| Профит всех ордеров по типу ордера                               |
//+------------------------------------------------------------------+
double AllProfit(int ot=-1)
  {
   double pr=0;
   for(int i=OrdersTotal()-1;i>=0;i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderMagicNumber()==Magic)
           {
            if(OrderType()==0 && (ot==0 || ot==-1))
              {
               pr+=OrderProfit()+OrderCommission()+OrderSwap();
              }

            if(OrderType()==1 && (ot==1 || ot==-1))
              {
               pr+=OrderProfit()+OrderCommission()+OrderSwap();
              }
           }
        }
     }
   return(pr);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   double ask1=MarketInfo(Symb1,MODE_ASK);
   double ask2=MarketInfo(Symb2,MODE_ASK);
   double bid1=MarketInfo(Symb1,MODE_BID);
   double bid2=MarketInfo(Symb2,MODE_BID);
   int order_result;

   if(ObjectGetInteger(0,"O",OBJPROP_STATE)==1)
     {
      if(Side1==0) order_result = PutOrder(Symb1,0,ask1,Lot1);
      if(Side1==1) order_result = PutOrder(Symb1,1,bid1,Lot1);
      if(Side2==0) order_result = PutOrder(Symb1,0,ask2,Lot2);
      if(Side2==1) order_result = PutOrder(Symb2,1,bid2,Lot2);
      if(order_result > 0){
         BuildOpenAlert();
      }          
      ObjectSetInteger(0,"O",OBJPROP_STATE,0);
     }

   if(ObjectGetInteger(0,"C",OBJPROP_STATE)==1)
     {
      CloseAll();
      ObjectSetInteger(0,"С",OBJPROP_STATE,0);
     }

   if(AllProfit()>Profit && Profit>0) CloseAll();
   if(AllProfit()<-Loss && Loss>0) CloseAll();
   
   Comment("\n Profit: ",AllProfit());
   //123
   // 345
  }
//+------------------------------------------------------------------+

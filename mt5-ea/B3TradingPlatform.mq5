//+------------------------------------------------------------------+
//| B3 Trading Platform Expert Advisor                              |
//| Integração com API da plataforma                                |
//+------------------------------------------------------------------+
#property copyright "B3 Trading Platform"
#property version   "1.00"
#property strict

// Parâmetros de entrada
input string ApiUrl = "http://localhost:8000";
input string ApiKey = "your-api-key-here";
input double RiskPercent = 2.0;
input int MagicNumber = 123456;
input bool EnableWebSocket = true;

// Variáveis globais
datetime lastTradeTime;
double accountBalance;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    Print("🚀 Inicializando B3 Trading Platform EA...");
    
    // Verificar se WebRequest está habilitado
    if(!TerminalInfoInteger(TERMINAL_DLLS_ALLOWED))
    {
        Alert("Habilite DLLs nas configurações do MetaTrader!");
        return INIT_FAILED;
    }
    
    // Obter saldo da conta
    accountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
    
    // Enviar status de inicialização para a API
    SendStatusToApi("EA_STARTED");
    
    Print("✅ EA inicializado com sucesso!");
    return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    Print("🛑 Finalizando B3 Trading Platform EA...");
    SendStatusToApi("EA_STOPPED");
}

//+------------------------------------------------------------------+
//| Expert tick function                                            |
//+------------------------------------------------------------------+
void OnTick()
{
    // Verificar se é horário de trading
    if(!IsTradingTime())
        return;
    
    // Enviar dados de mercado para a API
    SendMarketDataToApi();
    
    // Verificar sinais da API
    CheckApiSignals();
}

//+------------------------------------------------------------------+
//| Verificar horário de trading                                    |
//+------------------------------------------------------------------+
bool IsTradingTime()
{
    datetime currentTime = TimeLocal();
    int hour = TimeHour(currentTime);
    
    // Horário de pregão B3: 10:00 às 17:00
    return (hour >= 10 && hour < 17);
}

//+------------------------------------------------------------------+
//| Enviar dados de mercado para API                               |
//+------------------------------------------------------------------+
void SendMarketDataToApi()
{
    string symbol = _Symbol;
    double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
    double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
    long volume = SymbolInfoInteger(symbol, SYMBOL_VOLUME);
    
    string jsonData = StringFormat(
        "{\"symbol\":\"%s\",\"bid\":%.5f,\"ask\":%.5f,\"volume\":%d,\"timestamp\":\"%s\"}",
        symbol, bid, ask, volume, TimeToString(TimeCurrent())
    );
    
    // Enviar para API
    string url = ApiUrl + "/api/v1/mt5/market-data";
    SendHttpRequest(url, jsonData, "POST");
}

//+------------------------------------------------------------------+
//| Verificar sinais da API                                        |
//+------------------------------------------------------------------+
void CheckApiSignals()
{
    string url = ApiUrl + "/api/v1/mt5/signals?symbol=" + _Symbol;
    string response = SendHttpRequest(url, "", "GET");
    
    if(response != "")
    {
        // Processar resposta da API
        ProcessApiResponse(response);
    }
}

//+------------------------------------------------------------------+
//| Processar resposta da API                                      |
//+------------------------------------------------------------------+
void ProcessApiResponse(string response)
{
    // Aqui você pode implementar o parsing do JSON
    // Por simplicidade, vamos verificar palavras-chave
    
    if(StringFind(response, "BUY") >= 0)
    {
        ExecuteBuyOrder();
    }
    else if(StringFind(response, "SELL") >= 0)
    {
        ExecuteSellOrder();
    }
}

//+------------------------------------------------------------------+
//| Executar ordem de compra                                       |
//+------------------------------------------------------------------+
void ExecuteBuyOrder()
{
    double lotSize = CalculateLotSize();
    double price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
    double sl = price - (100 * _Point);  // Stop Loss
    double tp = price + (200 * _Point);  // Take Profit
    
    MqlTradeRequest request = {};
    MqlTradeResult result = {};
    
    request.action = TRADE_ACTION_DEAL;
    request.symbol = _Symbol;
    request.volume = lotSize;
    request.type = ORDER_TYPE_BUY;
    request.price = price;
    request.sl = sl;
    request.tp = tp;
    request.magic = MagicNumber;
    request.comment = "B3 Platform BUY";
    
    if(OrderSend(request, result))
    {
        Print("✅ Ordem de compra executada: ", result.order);
        SendTradeToApi("BUY", lotSize, price, result.order);
    }
    else
    {
        Print("❌ Erro ao executar ordem de compra: ", GetLastError());
    }
}

//+------------------------------------------------------------------+
//| Executar ordem de venda                                        |
//+------------------------------------------------------------------+
void ExecuteSellOrder()
{
    double lotSize = CalculateLotSize();
    double price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
    double sl = price + (100 * _Point);  // Stop Loss
    double tp = price - (200 * _Point);  // Take Profit
    
    MqlTradeRequest request = {};
    MqlTradeResult result = {};
    
    request.action = TRADE_ACTION_DEAL;
    request.symbol = _Symbol;
    request.volume = lotSize;
    request.type = ORDER_TYPE_SELL;
    request.price = price;
    request.sl = sl;
    request.tp = tp;
    request.magic = MagicNumber;
    request.comment = "B3 Platform SELL";
    
    if(OrderSend(request, result))
    {
        Print("✅ Ordem de venda executada: ", result.order);
        SendTradeToApi("SELL", lotSize, price, result.order);
    }
    else
    {
        Print("❌ Erro ao executar ordem de venda: ", GetLastError());
    }
}

//+------------------------------------------------------------------+
//| Calcular tamanho do lote baseado no risco                     |
//+------------------------------------------------------------------+
double CalculateLotSize()
{
    double balance = AccountInfoDouble(ACCOUNT_BALANCE);
    double riskAmount = balance * (RiskPercent / 100.0);
    
    // Cálculo simplificado do lote
    double lotSize = MathMin(riskAmount / 1000, 1.0);  // Máximo 1 lote
    lotSize = MathMax(lotSize, 0.01);  // Mínimo 0.01 lote
    
    return NormalizeDouble(lotSize, 2);
}

//+------------------------------------------------------------------+
//| Enviar trade para API                                          |
//+------------------------------------------------------------------+
void SendTradeToApi(string type, double volume, double price, long orderId)
{
    string jsonData = StringFormat(
        "{\"type\":\"%s\",\"symbol\":\"%s\",\"volume\":%.2f,\"price\":%.5f,\"order_id\":%d,\"timestamp\":\"%s\"}",
        type, _Symbol, volume, price, orderId, TimeToString(TimeCurrent())
    );
    
    string url = ApiUrl + "/api/v1/mt5/trades";
    SendHttpRequest(url, jsonData, "POST");
}

//+------------------------------------------------------------------+
//| Enviar status para API                                         |
//+------------------------------------------------------------------+
void SendStatusToApi(string status)
{
    string jsonData = StringFormat(
        "{\"status\":\"%s\",\"symbol\":\"%s\",\"timestamp\":\"%s\"}",
        status, _Symbol, TimeToString(TimeCurrent())
    );
    
    string url = ApiUrl + "/api/v1/mt5/status";
    SendHttpRequest(url, jsonData, "POST");
}

//+------------------------------------------------------------------+
//| Enviar requisição HTTP                                         |
//+------------------------------------------------------------------+
string SendHttpRequest(string url, string data, string method)
{
    char post[], result[];
    string headers = "Content-Type: application/json\r\n";
    
    if(data != "")
    {
        StringToCharArray(data, post, 0, StringLen(data));
    }
    
    int res = WebRequest(method, url, headers, "", 5000, post, result, headers);
    
    if(res == 200)
    {
        return CharArrayToString(result);
    }
    else
    {
        Print("Erro HTTP: ", res);
        return "";
    }
}

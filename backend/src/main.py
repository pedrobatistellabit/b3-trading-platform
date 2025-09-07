from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware
import uvicorn
import asyncio
import json
import random
from datetime import datetime
import logging

# Configurar logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(
    title="B3 Trading Platform API",
    description="API completa para trading na B3 com integração MetaTrader 5",
    version="1.0.0"
)

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Simulador de dados de mercado
class MarketDataSimulator:
    def __init__(self):
        self.symbols = {
            "WINFUT": {"price": 118500, "change": 0},
            "WDOFUT": {"price": 5.45, "change": 0}
        }
    
    def get_tick(self, symbol):
        if symbol in self.symbols:
            # Simular variação de preço
            variation = random.uniform(-0.5, 0.5)
            self.symbols[symbol]["price"] += variation
            self.symbols[symbol]["change"] = variation
            
            return {
                "symbol": symbol,
                "price": round(self.symbols[symbol]["price"], 2),
                "change": round(variation, 2),
                "timestamp": datetime.now().isoformat(),
                "volume": random.randint(100, 1000)
            }
        return None

market_simulator = MarketDataSimulator()

# Gerenciador de conexões WebSocket
class ConnectionManager:
    def __init__(self):
        self.active_connections: list = []

    async def connect(self, websocket: WebSocket):
        await websocket.accept()
        self.active_connections.append(websocket)
        logger.info(f"Nova conexão WebSocket: {len(self.active_connections)} conexões ativas")

    def disconnect(self, websocket: WebSocket):
        if websocket in self.active_connections:
            self.active_connections.remove(websocket)
        logger.info(f"Conexão WebSocket removida: {len(self.active_connections)} conexões ativas")

    async def broadcast(self, message: str):
        disconnected = []
        for connection in self.active_connections:
            try:
                await connection.send_text(message)
            except:
                disconnected.append(connection)
        
        # Remove conexões mortas
        for conn in disconnected:
            self.disconnect(conn)

manager = ConnectionManager()

# Endpoints REST
@app.get("/")
async def root():
    return {
        "message": "🚀 B3 Trading Platform API está rodando!",
        "status": "online",
        "timestamp": datetime.now().isoformat()
    }

@app.get("/health")
async def health_check():
    return {
        "status": "healthy",
        "service": "b3-trading-api",
        "timestamp": datetime.now().isoformat(),
        "connections": len(manager.active_connections)
    }

@app.get("/api/v1/market/{symbol}")
async def get_market_data(symbol: str):
    tick = market_simulator.get_tick(symbol.upper())
    if tick:
        return tick
    return {"error": "Symbol not found"}

@app.post("/api/v1/trade")
async def execute_trade(trade_data: dict):
    # Simular execução de trade
    trade_id = random.randint(1000, 9999)
    
    response = {
        "trade_id": trade_id,
        "symbol": trade_data.get("symbol", "WINFUT"),
        "side": trade_data.get("side", "BUY"),
        "quantity": trade_data.get("quantity", 1),
        "price": market_simulator.symbols.get(trade_data.get("symbol", "WINFUT"), {}).get("price", 0),
        "status": "FILLED",
        "timestamp": datetime.now().isoformat()
    }
    
    # Broadcast para WebSocket
    await manager.broadcast(json.dumps({
        "type": "trade_executed",
        "data": response
    }))
    
    logger.info(f"Trade executado: {response}")
    return response

@app.get("/api/v1/positions")
async def get_positions():
    # Simular posições
    return [
        {
            "symbol": "WINFUT",
            "quantity": 2,
            "avg_price": 118450,
            "current_price": market_simulator.symbols["WINFUT"]["price"],
            "pnl": (market_simulator.symbols["WINFUT"]["price"] - 118450) * 2
        }
    ]

@app.get("/api/v1/account")
async def get_account():
    return {
        "balance": 50000.00,
        "equity": 52500.00,
        "margin": 5000.00,
        "free_margin": 47500.00,
        "margin_level": 1050.00
    }

# WebSocket para dados em tempo real
@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    await manager.connect(websocket)
    try:
        # Enviar dados de mercado em tempo real
        while True:
            # Simular dados para WINFUT e WDOFUT
            for symbol in ["WINFUT", "WDOFUT"]:
                tick = market_simulator.get_tick(symbol)
                message = {
                    "type": "market_data",
                    "data": tick
                }
                await websocket.send_text(json.dumps(message))
            
            await asyncio.sleep(1)  # Atualizar a cada segundo
            
    except WebSocketDisconnect:
        manager.disconnect(websocket)

# Simulação de Expert Advisor
@app.post("/api/v1/mt5/signal")
async def receive_mt5_signal(signal_data: dict):
    logger.info(f"Sinal recebido do MT5: {signal_data}")
    
    # Processar sinal e executar trade se necessário
    if signal_data.get("action") == "BUY" or signal_data.get("action") == "SELL":
        trade_response = await execute_trade({
            "symbol": signal_data.get("symbol", "WINFUT"),
            "side": signal_data.get("action"),
            "quantity": signal_data.get("volume", 1)
        })
        return trade_response
    
    return {"status": "signal_received", "message": "Sinal processado"}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)

#!/usr/bin/env python3
import asyncio
import redis
import json
import random
from datetime import datetime
import os

# Conectar ao Redis
redis_client = redis.Redis(
    host='redis',
    port=6379,
    password=os.getenv('REDIS_PASSWORD'),
    db=1,
    decode_responses=True
)

async def simulate_market_data():
    """Simula dados de mercado em tempo real"""
    
    symbols = {
        "WINFUT": 118500,
        "WDOFUT": 5.45,
        "PETR4": 32.50,
        "VALE3": 65.80,
        "ITUB4": 28.90
    }
    
    while True:
        for symbol, base_price in symbols.items():
            # Simular variação de preço
            variation = random.uniform(-0.5, 0.5)
            new_price = base_price + variation
            
            # Dados de mercado
            market_data = {
                "symbol": symbol,
                "price": round(new_price, 2),
                "change": round(variation, 2),
                "change_percent": round((variation / base_price) * 100, 3),
                "volume": random.randint(1000, 10000),
                "timestamp": datetime.now().isoformat(),
                "bid": round(new_price - 0.1, 2),
                "ask": round(new_price + 0.1, 2)
            }
            
            # Publicar no Redis
            redis_client.publish('market_data', json.dumps(market_data))
            redis_client.setex(f"price:{symbol}", 60, new_price)
            
            # Atualizar preço base
            symbols[symbol] = new_price
        
        await asyncio.sleep(0.5)  # Atualizar a cada 500ms

if __name__ == "__main__":
    print("🔄 Iniciando simulador de dados de mercado...")
    asyncio.run(simulate_market_data())

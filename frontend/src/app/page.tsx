'use client'

import { useState, useEffect } from 'react'
import axios from 'axios'

// Get API URL from environment variable, fallback to localhost for development
const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000'
const WS_URL = API_URL.replace('http', 'ws')

interface MarketData {
  symbol: string
  price: number
  change: number
  timestamp: string
  volume: number
}

interface Position {
  symbol: string
  quantity: number
  avg_price: number
  current_price: number
  pnl: number
}

export default function Dashboard() {
  const [marketData, setMarketData] = useState<MarketData[]>([])
  const [positions, setPositions] = useState<Position[]>([])
  const [account, setAccount] = useState<any>({})
  const [isConnected, setIsConnected] = useState(false)

  useEffect(() => {
    // Conectar WebSocket
    const ws = new WebSocket(`${WS_URL}/ws`)
    
    ws.onopen = () => {
      setIsConnected(true)
      console.log('WebSocket conectado')
    }
    
    ws.onmessage = (event) => {
      const message = JSON.parse(event.data)
      if (message.type === 'market_data') {
        setMarketData(prev => {
          const updated = prev.filter(item => item.symbol !== message.data.symbol)
          return [...updated, message.data]
        })
      }
    }
    
    ws.onclose = () => {
      setIsConnected(false)
      console.log('WebSocket desconectado')
    }

    // Carregar dados iniciais
    loadInitialData()

    return () => {
      ws.close()
    }
  }, [])

  const loadInitialData = async () => {
    try {
      const [positionsRes, accountRes] = await Promise.all([
        axios.get(`${API_URL}/api/v1/positions`),
        axios.get(`${API_URL}/api/v1/account`)
      ])
      
      setPositions(positionsRes.data)
      setAccount(accountRes.data)
    } catch (error) {
      console.error('Erro ao carregar dados:', error)
    }
  }

  const executeTrade = async (symbol: string, side: string) => {
    try {
      const response = await axios.post(`${API_URL}/api/v1/trade`, {
        symbol,
        side,
        quantity: 1
      })
      
      console.log('Trade executado:', response.data)
      loadInitialData() // Recarregar dados
    } catch (error) {
      console.error('Erro ao executar trade:', error)
    }
  }

  return (
    <div className="min-h-screen bg-gray-900 text-white p-6">
      <header className="mb-8">
        <h1 className="text-4xl font-bold text-blue-400">
          🚀 B3 Trading Platform
        </h1>
        <div className="flex items-center mt-2">
          <div className={`w-3 h-3 rounded-full mr-2 ${isConnected ? 'bg-green-500' : 'bg-red-500'}`}></div>
          <span>{isConnected ? 'Conectado' : 'Desconectado'}</span>
        </div>
      </header>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Market Data */}
        <div className="bg-gray-800 rounded-lg p-6">
          <h2 className="text-xl font-semibold mb-4 text-blue-300">📈 Dados de Mercado</h2>
          <div className="space-y-3">
            {marketData.map((data) => (
              <div key={data.symbol} className="bg-gray-700 rounded p-4">
                <div className="flex justify-between items-center">
                  <span className="font-bold">{data.symbol}</span>
                  <span className={`${data.change >= 0 ? 'text-green-400' : 'text-red-400'}`}>
                    {data.change >= 0 ? '+' : ''}{data.change.toFixed(2)}
                  </span>
                </div>
                <div className="text-2xl font-bold">{data.price.toFixed(2)}</div>
                <div className="text-sm text-gray-400">Vol: {data.volume}</div>
                <div className="mt-3 space-x-2">
                  <button 
                    onClick={() => executeTrade(data.symbol, 'BUY')}
                    className="bg-green-600 hover:bg-green-700 px-3 py-1 rounded text-sm"
                  >
                    COMPRAR
                  </button>
                  <button 
                    onClick={() => executeTrade(data.symbol, 'SELL')}
                    className="bg-red-600 hover:bg-red-700 px-3 py-1 rounded text-sm"
                  >
                    VENDER
                  </button>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Account Info */}
        <div className="bg-gray-800 rounded-lg p-6">
          <h2 className="text-xl font-semibold mb-4 text-green-300">💰 Conta</h2>
          <div className="space-y-3">
            <div className="flex justify-between">
              <span>Saldo:</span>
              <span className="font-bold">R$ {account.balance?.toLocaleString()}</span>
            </div>
            <div className="flex justify-between">
              <span>Patrimônio:</span>
              <span className="font-bold">R$ {account.equity?.toLocaleString()}</span>
            </div>
            <div className="flex justify-between">
              <span>Margem:</span>
              <span>R$ {account.margin?.toLocaleString()}</span>
            </div>
            <div className="flex justify-between">
              <span>Margem Livre:</span>
              <span>R$ {account.free_margin?.toLocaleString()}</span>
            </div>
            <div className="flex justify-between">
              <span>Nível de Margem:</span>
              <span className="text-blue-400">{account.margin_level?.toFixed(2)}%</span>
            </div>
          </div>
        </div>

        {/* Positions */}
        <div className="bg-gray-800 rounded-lg p-6">
          <h2 className="text-xl font-semibold mb-4 text-purple-300">📊 Posições</h2>
          <div className="space-y-3">
            {positions.map((position, index) => (
              <div key={index} className="bg-gray-700 rounded p-4">
                <div className="flex justify-between items-center">
                  <span className="font-bold">{position.symbol}</span>
                  <span className={`${position.pnl >= 0 ? 'text-green-400' : 'text-red-400'}`}>
                    {position.pnl >= 0 ? '+' : ''}R$ {position.pnl.toFixed(2)}
                  </span>
                </div>
                <div className="text-sm text-gray-400">
                  Qtd: {position.quantity} | Preço Médio: {position.avg_price}
                </div>
                <div className="text-sm text-gray-400">
                  Preço Atual: {position.current_price.toFixed(2)}
                </div>
              </div>
            ))}
            {positions.length === 0 && (
              <div className="text-gray-400 text-center py-4">
                Nenhuma posição aberta
              </div>
            )}
          </div>
        </div>
      </div>

      {/* Footer */}
      <footer className="mt-8 text-center text-gray-400">
        <p>🤖 B3 Trading Platform - Deploy Automático Concluído com Sucesso! 🚀</p>
      </footer>
    </div>
  )
}

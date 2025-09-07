-- B3 Trading Platform - Inicialização do Banco de Dados

-- Criar schema principal
CREATE SCHEMA IF NOT EXISTS trading;

-- Tabela de usuários
CREATE TABLE IF NOT EXISTS trading.users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    is_active BOOLEAN DEFAULT true,
    is_admin BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de contas de trading
CREATE TABLE IF NOT EXISTS trading.accounts (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES trading.users(id),
    account_number VARCHAR(50) UNIQUE NOT NULL,
    broker VARCHAR(100) NOT NULL,
    account_type VARCHAR(20) DEFAULT 'demo',
    balance DECIMAL(15,2) DEFAULT 0,
    equity DECIMAL(15,2) DEFAULT 0,
    margin DECIMAL(15,2) DEFAULT 0,
    free_margin DECIMAL(15,2) DEFAULT 0,
    margin_level DECIMAL(8,2) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de símbolos
CREATE TABLE IF NOT EXISTS trading.symbols (
    id SERIAL PRIMARY KEY,
    symbol VARCHAR(20) UNIQUE NOT NULL,
    description VARCHAR(200),
    exchange VARCHAR(50) DEFAULT 'B3',
    asset_type VARCHAR(50),
    tick_size DECIMAL(10,8),
    min_volume DECIMAL(10,4),
    max_volume DECIMAL(10,4),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de ordens
CREATE TABLE IF NOT EXISTS trading.orders (
    id SERIAL PRIMARY KEY,
    account_id INTEGER REFERENCES trading.accounts(id),
    symbol_id INTEGER REFERENCES trading.symbols(id),
    order_id VARCHAR(50) UNIQUE NOT NULL,
    type VARCHAR(20) NOT NULL, -- BUY, SELL
    volume DECIMAL(10,4) NOT NULL,
    price DECIMAL(15,5),
    stop_loss DECIMAL(15,5),
    take_profit DECIMAL(15,5),
    status VARCHAR(20) DEFAULT 'PENDING', -- PENDING, FILLED, CANCELLED
    executed_price DECIMAL(15,5),
    executed_volume DECIMAL(10,4),
    commission DECIMAL(10,2) DEFAULT 0,
    swap DECIMAL(10,2) DEFAULT 0,
    profit DECIMAL(15,2) DEFAULT 0,
    magic_number INTEGER,
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    executed_at TIMESTAMP
);

-- Tabela de posições
CREATE TABLE IF NOT EXISTS trading.positions (
    id SERIAL PRIMARY KEY,
    account_id INTEGER REFERENCES trading.accounts(id),
    symbol_id INTEGER REFERENCES trading.symbols(id),
    position_id VARCHAR(50) UNIQUE NOT NULL,
    type VARCHAR(20) NOT NULL, -- BUY, SELL
    volume DECIMAL(10,4) NOT NULL,
    open_price DECIMAL(15,5) NOT NULL,
    current_price DECIMAL(15,5),
    stop_loss DECIMAL(15,5),
    take_profit DECIMAL(15,5),
    commission DECIMAL(10,2) DEFAULT 0,
    swap DECIMAL(10,2) DEFAULT 0,
    profit DECIMAL(15,2) DEFAULT 0,
    magic_number INTEGER,
    comment TEXT,
    opened_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    closed_at TIMESTAMP
);

-- Tabela de dados de mercado (para histórico)
CREATE TABLE IF NOT EXISTS trading.market_data (
    id SERIAL PRIMARY KEY,
    symbol_id INTEGER REFERENCES trading.symbols(id),
    timestamp TIMESTAMP NOT NULL,
    bid DECIMAL(15,5) NOT NULL,
    ask DECIMAL(15,5) NOT NULL,
    volume BIGINT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela de logs de API
CREATE TABLE IF NOT EXISTS trading.api_logs (
    id SERIAL PRIMARY KEY,
    endpoint VARCHAR(200),
    method VARCHAR(10),
    status_code INTEGER,
    response_time INTEGER, -- em ms
    user_id INTEGER REFERENCES trading.users(id),
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Inserir dados iniciais
INSERT INTO trading.symbols (symbol, description, exchange, asset_type, tick_size, min_volume, max_volume) VALUES
('WINFUT', 'Mini Índice Bovespa Futuro', 'B3', 'INDEX_FUTURE', 5, 1, 100),
('WDOFUT', 'Mini Dólar Futuro', 'B3', 'CURRENCY_FUTURE', 0.5, 1, 100),
('PETR4', 'Petrobras PN', 'B3', 'STOCK', 0.01, 100, 10000),
('VALE3', 'Vale ON', 'B3', 'STOCK', 0.01, 100, 10000),
('ITUB4', 'Itaú Unibanco PN', 'B3', 'STOCK', 0.01, 100, 10000);

-- Criar usuário admin padrão (senha: admin123)
INSERT INTO trading.users (username, email, password_hash, is_admin) VALUES
('admin', 'admin@b3platform.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewYhqzHTzLpPRK.K', true);

-- Criar conta demo
INSERT INTO trading.accounts (user_id, account_number, broker, account_type, balance, equity, free_margin) VALUES
(1, 'DEMO001', 'B3 Demo Broker', 'demo', 50000.00, 50000.00, 50000.00);

-- Índices para performance
CREATE INDEX IF NOT EXISTS idx_orders_account_id ON trading.orders(account_id);
CREATE INDEX IF NOT EXISTS idx_orders_symbol_id ON trading.orders(symbol_id);
CREATE INDEX IF NOT EXISTS idx_orders_created_at ON trading.orders(created_at);
CREATE INDEX IF NOT EXISTS idx_positions_account_id ON trading.positions(account_id);
CREATE INDEX IF NOT EXISTS idx_market_data_symbol_timestamp ON trading.market_data(symbol_id, timestamp);
CREATE INDEX IF NOT EXISTS idx_api_logs_created_at ON trading.api_logs(created_at);

-- Função para atualizar timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers para atualizar updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON trading.users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_accounts_updated_at BEFORE UPDATE ON trading.accounts FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_orders_updated_at BEFORE UPDATE ON trading.orders FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_positions_updated_at BEFORE UPDATE ON trading.positions FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Conceder permissões
GRANT ALL PRIVILEGES ON SCHEMA trading TO trader;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA trading TO trader;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA trading TO trader;

COMMIT;

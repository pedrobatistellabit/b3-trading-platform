# GitHub Copilot Instructions for B3 Trading Platform

## Project Overview

B3 Trading Platform is a comprehensive algorithmic trading system for the Brazilian stock exchange (B3). The platform consists of multiple integrated components providing real-time market data, trading execution, risk management, and portfolio monitoring capabilities.

## Architecture

This is a microservices-based platform with the following components:

- **Backend API**: FastAPI (Python) - Core trading engine and API
- **Frontend Dashboard**: Next.js (TypeScript/React) - Web interface for monitoring and control
- **MetaTrader 5 EA**: MQL5 Expert Advisor - Bridge between MT5 and the platform
- **Market Data Service**: Python service for real-time market data simulation/collection
- **Database**: PostgreSQL for persistent data storage
- **Cache**: Redis for real-time data and session management
- **Monitoring**: Grafana for system observability

## Code Style and Standards

### General Principles
- Write clear, self-documenting code with meaningful variable and function names
- Follow language-specific conventions and best practices
- Prioritize code readability and maintainability
- Use consistent formatting throughout the codebase
- Add comments for complex business logic, especially trading algorithms

### Python (Backend & Services)
- Follow PEP 8 style guidelines
- Use type hints for all function parameters and return values
- Use dataclasses or Pydantic models for structured data
- Implement proper error handling with specific exception types
- Use async/await for I/O operations
- Structure code using dependency injection patterns
- Prefer SQLAlchemy ORM over raw SQL queries
- Use environment variables for configuration

Example:
```python
from typing import Optional
from pydantic import BaseModel
from datetime import datetime

class TradeOrder(BaseModel):
    symbol: str
    quantity: float
    price: Optional[float] = None
    order_type: str
    created_at: datetime
    
async def execute_trade(order: TradeOrder) -> dict:
    """Execute a trade order with proper validation and error handling."""
    # Implementation here
    pass
```

### TypeScript/React (Frontend)
- Use TypeScript for all new code
- Follow React hooks patterns and functional components
- Use Tailwind CSS for styling with semantic class names
- Implement proper error boundaries and loading states
- Use axios for API calls with proper error handling
- Structure components with clear prop interfaces
- Use Next.js app router conventions

Example:
```typescript
interface PositionProps {
  symbol: string;
  quantity: number;
  currentPrice: number;
  pnl: number;
}

export function PositionCard({ symbol, quantity, currentPrice, pnl }: PositionProps) {
  const pnlColor = pnl >= 0 ? 'text-green-400' : 'text-red-400';
  
  return (
    <div className="bg-gray-800 rounded-lg p-4">
      {/* Component implementation */}
    </div>
  );
}
```

### MQL5 (MetaTrader Expert Advisor)
- Use descriptive function and variable names
- Implement proper error handling with GetLastError()
- Use Magic Numbers to identify trades
- Follow MQL5 coding standards and conventions
- Add comprehensive logging for debugging
- Implement proper position sizing and risk management

## Project Structure

```
/
├── backend/              # FastAPI backend service
│   ├── src/
│   │   ├── main.py      # FastAPI application entry point
│   │   ├── models/      # SQLAlchemy models
│   │   ├── routes/      # API route handlers
│   │   └── services/    # Business logic layer
│   ├── requirements.txt
│   └── Dockerfile
├── frontend/            # Next.js React application
│   ├── src/
│   │   ├── app/        # Next.js app router
│   │   ├── components/ # Reusable React components
│   │   └── types/      # TypeScript type definitions
│   ├── package.json
│   └── Dockerfile
├── mt5-ea/             # MetaTrader 5 Expert Advisor
│   ├── B3TradingPlatform.mq5
│   └── docs/
├── services/
│   └── market-data/    # Market data simulation service
├── database/
│   └── init.sql        # Database initialization
└── docker-compose.yml  # Container orchestration
```

## Domain-Specific Guidelines

### Trading and Financial Context
- Always implement proper position sizing and risk management
- Use appropriate decimal precision for financial calculations (avoid floating point errors)
- Implement circuit breakers and safety limits
- Log all trading operations for audit purposes
- Handle market hours and trading session validation
- Implement proper order validation before execution

### Security Considerations
- Never log sensitive information (API keys, passwords, account details)
- Validate all user inputs, especially trading parameters
- Implement rate limiting for trading operations
- Use secure communication protocols for external APIs
- Store configuration in environment variables, not code

### Performance Guidelines
- Use Redis caching for frequently accessed market data
- Implement database connection pooling
- Use async operations for I/O-bound tasks
- Optimize database queries with proper indexing
- Implement proper pagination for large datasets
- Use WebSockets for real-time data updates

## Common Patterns

### Database Operations
- Use SQLAlchemy async sessions
- Implement proper transaction handling
- Use database migrations for schema changes
- Follow repository pattern for data access

### API Design
- Use RESTful conventions
- Implement proper HTTP status codes
- Include comprehensive error messages
- Use request/response models for validation
- Implement API versioning (e.g., /api/v1/)

### Error Handling
- Use structured logging with appropriate levels
- Implement graceful degradation for external service failures
- Provide meaningful error messages to users
- Use proper exception hierarchy

### Testing
- Write unit tests for business logic
- Use integration tests for API endpoints
- Mock external dependencies
- Test edge cases and error conditions
- Maintain test coverage for critical trading functions

## Environment and Configuration

- Use environment variables for all configuration
- Separate development, staging, and production configs
- Never commit secrets or API keys to version control
- Use Docker for consistent development environments
- Document all required environment variables

## Trading-Specific Best Practices

### Risk Management
- Always implement stop-loss mechanisms
- Use position sizing based on account balance
- Implement maximum daily loss limits
- Validate order parameters before execution
- Monitor margin levels and account equity

### Market Data Handling
- Handle market closures and holidays
- Implement data validation for price feeds
- Use appropriate timeframes for analysis
- Handle missing or delayed data gracefully
- Cache frequently accessed symbols and data

### Order Management
- Generate unique order IDs
- Track order states and lifecycle
- Implement order modification and cancellation
- Handle partial fills appropriately
- Log all order operations with timestamps

## When Contributing

1. Understand the trading domain context before making changes
2. Test thoroughly with demo accounts before production
3. Follow the established patterns in the codebase
4. Update documentation when adding new features
5. Consider the impact on real-time trading operations
6. Implement proper logging for troubleshooting

## Helpful Commands

```bash
# Start development environment
docker-compose up -d

# Backend development
cd backend && uvicorn src.main:app --reload

# Frontend development  
cd frontend && npm run dev

# Database migrations
cd backend && alembic upgrade head

# Run tests
cd backend && pytest
cd frontend && npm test
```

Remember: This is a financial trading system. Always prioritize safety, accuracy, and proper risk management in all code changes.
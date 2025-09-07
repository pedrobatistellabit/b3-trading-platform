# 📖 Instalação do Expert Advisor B3 Trading Platform

## Pré-requisitos
- MetaTrader 5 instalado
- Conta demo ou real em corretora que suporte B3
- Plataforma B3 Trading rodando (backend)

## Passos de Instalação

### 1. Copiar o Expert Advisor
```bash
# Copie o arquivo para a pasta do MT5
cp B3TradingPlatform.mq5 "C:\Users\SeuUsuario\AppData\Roaming\MetaQuotes\Terminal\[ID_INSTALACAO]\MQL5\Experts\"
```

### 2. Configurar MetaTrader 5
1. Abra o MetaTrader 5
2. Vá em **Ferramentas > Opções**
3. Na aba **Expert Advisors**:
   - ✅ Marque "Permitir trading automatizado"
   - ✅ Marque "Permitir DLL imports"
   - ✅ Marque "Permitir WebRequest para URLs listadas"
   - Adicione: `http://localhost:8000`

### 3. Compilar o EA
1. Pressione F4 para abrir MetaEditor
2. Abra o arquivo B3TradingPlatform.mq5
3. Pressione F7 para compilar
4. Verifique se não há erros

### 4. Aplicar no Gráfico
1. No MT5, vá para Navigator > Expert Advisors
2. Arraste B3TradingPlatform para um gráfico
3. Configure os parâmetros:
   - **ApiUrl**: http://localhost:8000 (ou seu servidor)
   - **RiskPercent**: 2.0 (2% de risco por trade)
   - **MagicNumber**: 123456 (único para este EA)

### 5. Verificar Funcionamento
- No terminal do MT5, você deve ver mensagens do EA
- Na plataforma web, verifique se dados estão sendo recebidos
- Teste com conta demo primeiro!

## ⚠️ Importante
- SEMPRE teste em conta demo primeiro
- Configure o risco adequadamente
- Monitore o EA constantemente
- Mantenha a plataforma backend rodando

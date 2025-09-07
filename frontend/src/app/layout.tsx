import './globals.css'

export const metadata = {
  title: 'B3 Trading Platform',
  description: 'Plataforma de trading para B3 com integração MetaTrader 5',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="pt-BR">
      <body>{children}</body>
    </html>
  )
}

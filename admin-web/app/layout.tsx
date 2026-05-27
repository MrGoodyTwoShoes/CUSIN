import './globals.css'
import type { Metadata } from 'next'

export const metadata: Metadata = {
  title: 'CUSIN Admin Dashboard',
  description: 'Civilian Urban Safety Intelligence Network - Admin Dashboard',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  )
}

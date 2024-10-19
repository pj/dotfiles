import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import App from './App.tsx'
import './index.css'
import { sendMessage } from './messages.ts'

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <App sendMessage={sendMessage} />
  </StrictMode>,
)

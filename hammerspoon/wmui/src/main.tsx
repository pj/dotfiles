import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import App from './App.tsx'
import './index.css'
import { sendMessage } from './messages.ts'
import { PrefixSelectCommand } from './PrefixSelectCommand.tsx'
import { VolumeCommand } from './VolumeCommand.tsx'

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <App 
      sendMessage={sendMessage} 
      RootCommand={PrefixSelectCommand} 
      RootCommandProps={{ 
        prefixes: new Map([['v', [VolumeCommand, 'Volume'] as [React.ComponentType<any>, string]]]) 
      }}
      setEventListener={listener => window.addEventListener('message', listener)}
      removeEventListener={listener => window.removeEventListener('message', listener)}
    />
  </StrictMode>,
)

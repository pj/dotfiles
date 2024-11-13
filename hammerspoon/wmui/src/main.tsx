import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import App from './App.tsx'
import './index.css'
import { PrefixSelectCommand } from './PrefixSelectCommand.tsx'
import { SiteBlockerCommand } from './SiteBlocker.tsx'
import { EditLayoutCommand } from './window_management/EditLayoutCommand.tsx'
import { SelectLayoutCommand } from './window_management/SelectLayoutCommand.tsx'
export function sendMessage(message: any) {
  // @ts-ignore
  webkit.messageHandlers.wmui.postMessage(message)
}

createRoot(document.getElementById('root')!).render(
    <StrictMode>
        <App
            sendMessage={sendMessage}
            RootCommand={PrefixSelectCommand}
            RootCommandProps={{
                prefixes: new Map([
                    ['b', {component: SiteBlockerCommand, props: {}, description: 'Site Blocker'}],
                    ['w', {component: EditLayoutCommand, props: {}, description: 'Window Management editor'}],
                    ['l', {component: SelectLayoutCommand, props: {}, description: 'Select Layout'}],
                ]),
                index: 0,
                handleDelete: () => {}
            }}
            setMessageListener={listener => window.addEventListener('message', listener)}
            removeMessageListener={listener => window.removeEventListener('message', listener)}
            debug={false}
        />
    </StrictMode>,
)

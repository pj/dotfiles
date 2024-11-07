import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import App from './App.tsx'
import './index.css'
import { PrefixSelectCommand } from './PrefixSelectCommand.tsx'
import { SiteBlockerCommand } from './SiteBlocker.tsx'
import { WindowManagementLayoutCommand } from './window_management/LayoutCommand.tsx'
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
                    ['w', {component: PrefixSelectCommand, props: {}, description: 'Window Management'}],
                    ['l', {component: WindowManagementLayoutCommand, props: {}, description: 'Window Management Layout'}],
                ]),
                index: 0,
                handleDelete: () => {}
            }}
            setMessageListener={listener => window.addEventListener('message', listener)}
            removeMessageListener={listener => window.removeEventListener('message', listener)}
            // setVisibilityChangeListener={listener => document.addEventListener('visibilitychange', listener)}
            // removeVisibilityChangeListener={listener => document.removeEventListener('visibilitychange', listener)}
            debug={false}
        />
    </StrictMode>,
)

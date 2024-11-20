import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import App from './App.tsx'
import './index.css'
import { Prefix, PrefixSelectCommand } from './PrefixSelectCommand.tsx'
import { SiteBlockerCommand } from './SiteBlocker.tsx'
// import { EditLayoutCommand } from './window_management/EditLayoutCommand.tsx'
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
                prefixes: new Map<string, Prefix>([
                    [
                        'b', 
                        {component: SiteBlockerCommand, props: {}, description: 'Site Blocker', type: "command"}
                    ],
                    // [
                    //     'w', 
                    //     {component: EditLayoutCommand, props: {}, description: 'Window Management editor', type: "command"}
                    // ],
                    [
                        'l', 
                        {component: SelectLayoutCommand, props: {}, description: 'Select Layout', type: "command"}
                    ],
                    [
                        'z', 
                        {
                            quickFunction: () => {
                                sendMessage({ type: "windowManagementZoomToggle" })
                            }, 
                            description: 'Toggle Zoom of focused window', 
                            type: "quickFunction"
                        }
                    ],
                    [
                        'f', 
                        {
                            quickFunction: () => {
                                sendMessage({ type: "windowManagementFloatToggle" })
                            }, 
                            description: 'Make focused window float', 
                            type: "quickFunction"
                        }
                    ],
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

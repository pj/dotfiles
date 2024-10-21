import { useCallback, useEffect, useState } from 'react'
import './index.css'
import { FromMessageSchema, ToMessage } from './messages'

type AppProps = {
    sendMessage: (message: ToMessage) => void,
    setEventListener: (listener: (event: MessageEvent) => void) => void,
    removeEventListener: (listener: (event: MessageEvent) => void) => void,
    RootCommand: React.ComponentType<any>,
    RootCommandProps: any
}

function App({ sendMessage, setEventListener, removeEventListener, RootCommand, RootCommandProps }: AppProps) {
    const [hammerspoonReady, setHammerspoonReady] = useState(false)

    const handleMessage = useCallback((event: MessageEvent) => {
        const message = FromMessageSchema.parse(event.data)

        sendMessage({ type: 'log', log: `received message: ${JSON.stringify(message)}` })

        if (message.type === 'hammerspoonReady') {
            setHammerspoonReady(true)
        }
    }, [])

    useEffect(() => {
        setEventListener(handleMessage)
        // Send message to hammerspoon to let it know the UI is ready
        sendMessage({
            type: 'uiReady'
        })

        return () => {
            removeEventListener(handleMessage)
        }
    }, [handleMessage])

    return (
        hammerspoonReady ? (
            <div className="flex flex-row border border-gray-200 rounded-lg p-3 shadow-lg bg-gray-100">
                <RootCommand index={0} {...RootCommandProps} />
            </div>
        ) : (
            <div data-testid="app-loading">Loading...</div>
        )
    )
}

export default App

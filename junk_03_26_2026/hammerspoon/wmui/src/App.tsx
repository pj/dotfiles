import { createContext, useCallback, useEffect, useReducer, useState } from 'react'
import './index.css'
import React from 'react';

type AppProps<RootCommandProps> = {
    sendMessage: (message: any) => void,
    setMessageListener: (listener: (event: MessageEvent) => void) => void,
    removeMessageListener: (listener: (event: MessageEvent) => void) => void,
    RootCommand: React.ComponentType<RootCommandProps>,
    RootCommandProps: RootCommandProps,
    debug: boolean,
}

export const AppStateContext = createContext<any>(null);
export const AppSendMessageContext = createContext<any>(null);
export const AppExitContext = createContext<any>(null);


class AppErrorBoundary extends React.Component<any, any> {
    constructor(props: any) {
        super(props);
        this.state = { error: null };
    }

    static getDerivedStateFromError(error: any) {
        return { error };
    }

    componentDidCatch(error: any, errorInfo: any) {
        this.props.sendMessage({ type: 'log', log: `error: ${error}, errorInfo: ${errorInfo}` })
    }

    render() {
        if (this.state.error) {
            return <div>Something went wrong: {this.state.error.toString()}</div>;
        }

        return this.props.children;
    }
}

function App<RootCommandProps>(
    {
        sendMessage,
        setMessageListener,
        removeMessageListener,
        RootCommand,
        RootCommandProps,
        debug
    }: AppProps<RootCommandProps>) {
    const [appState, dispatchAppState] = useReducer((state: any, action: any) => {
        if (action.type === 'resetState') {
            return { hammerspoonReady: true, cacheBusterKey: Math.random() }
        } else if (action.type === 'updateState') {
            return { ...state, ...action.data }
        }
    }, {hammerspoonReady: false, cacheBusterKey: Math.random()});

    const [lastMessage, setLastMessage] = useState<any>(null);

    const handleMessage = useCallback((event: any) => {
        // sendMessage({ type: 'log', log: `received message: ${JSON.stringify(event.data)}` })
        if (event.data.type === 'resetState') {
            dispatchAppState({type: 'resetState'});
        } else{
            dispatchAppState({ type: 'updateState', data:  {[event.data.type]: event.data }});
        }         
        setLastMessage(event.data)
    }, []);

    useEffect(() => {
        setMessageListener(handleMessage)

        sendMessage({
            type: 'uiReady'
        });

        return () => {
            removeMessageListener(handleMessage)
        }
    }, [handleMessage])

    const handleExit = useCallback(() => {
        sendMessage({ type: 'exit' })
    }, [sendMessage]);

    return (
        <AppErrorBoundary sendMessage={sendMessage}>
            <AppStateContext.Provider value={appState}>
                <AppSendMessageContext.Provider value={sendMessage}>
                    <AppExitContext.Provider value={handleExit}>
                        {
                            appState.hammerspoonReady ? (
                                <div key={appState.cacheBusterKey} className="bg-gray-100 shadow-xl flex flex-row flex-nowrap justify-start space-x-2.5 items-stretch border border-gray-200 rounded-lg p-2.5 h-full">
                                    <RootCommand index={0} {...RootCommandProps} />
                                </div>
                            ) : (
                                <div data-testid="app-loading">Loading...</div>
                            )
                        }
                        {debug && <div data-testid="last-message">LastMessage: {JSON.stringify(lastMessage, null, 4)}</div>}
                    </AppExitContext.Provider>
                </AppSendMessageContext.Provider>
            </AppStateContext.Provider>
        </AppErrorBoundary>
    )
}

export default App

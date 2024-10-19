import { useCallback, useEffect, useState } from 'react'
import './App.css'
import { FromMessageSchema, ToMessage } from './messages'
// import { Widget } from './command_interpreter'

type AppProps = { sendMessage: (message: ToMessage) => void }

function App({ sendMessage }: AppProps) {
    const [hammerspoonReady, setHammerspoonReady] = useState(false)

    // const [commandInterpreter, setCommandInterpreter] = useState(
    //     new CommandInterpreter(
    //         {
    //             action: (_: string) => {
    //                 return [null, [], false]
    //             }
    //         }
    //     )
    // )

    // const [widgets, setWidgets] = useState<Widget[]>([])

    const handleMessage = useCallback((event: MessageEvent) => {
        const message = FromMessageSchema.parse(event.data)

        sendMessage({ type: 'log', log: `received message: ${JSON.stringify(message)}` })

        if (message.type === 'hammerspoonReady') {
            setHammerspoonReady(true)
        } else if (message.type === 'resetCommandInterpreter') {
            // setCommandInterpreter(
            //     new CommandInterpreter(
            //         {
            //             action: (_: string) => {
            //                 return [null, [], false]
            //             }
            //         }
            //     )
            // )
        }
    }, [])

    useEffect(() => {
        window.addEventListener("message", handleMessage)
        // Send message to hammerspoon to let it know the UI is ready
        sendMessage({
            type: 'uiReady'
        })

        return () => {
            window.removeEventListener("message", handleMessage);
        }
    }, [handleMessage])

    function handleKeyUp(event: React.KeyboardEvent<HTMLDivElement>): void {
        sendMessage({
            type: 'log',
            log: `key up: ${event.key}`
        })
        event.stopPropagation()
        // const [widgets, completed] = commandInterpreter.key(event.key)
        // setWidgets(widgets)
        // if (completed) {
        //     setCommandInterpreter(
        //         new CommandInterpreter(
        //             {
        //                 action: (_: string) => {
        //                     return [null, [], false]
        //                 }
        //             }
        //         )
        //     )
        // }
    }

    return (
        hammerspoonReady ? (
            <div className="box" onKeyUp={handleKeyUp}>
                <div className="card">
                    {/* {widgets.map((Widget, index) => (
                        <Widget key={index} />
                    ))} */}
                </div>
            </div>
        ) : (
            <div>Loading...</div>
        )
    )
}

export default App

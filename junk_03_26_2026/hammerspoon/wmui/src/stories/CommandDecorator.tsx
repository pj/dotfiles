import App from "../App";

export function CommandDecorator(Command: React.ComponentType<any>, { args, parameters }: { args: any, parameters: any }) {
    let receiveMessage = (msg: any) => {
        parameters.commandMessaging.lastReceivedMessage = msg
        parameters.commandMessaging.lastReceivedMessages.push(msg)
    }

    parameters.commandMessaging.sendMessage = (msg: any) => {
        parameters.commandMessaging.onMessage(
            new MessageEvent('message', { data: msg })
        )
    }

    return (
        <App
            RootCommand={Command}
            RootCommandProps={{
                prefixes: args.prefixes,
                index: args.index
            }}
            sendMessage={receiveMessage}
            setMessageListener={onMessage => { parameters.commandMessaging.onMessage = onMessage }}
            removeMessageListener={_ => parameters.commandMessaging.onMessage = null}
            debug={args.debug}
        />
    )
}

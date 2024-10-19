import { fireEvent, render, screen } from "@testing-library/react";
import { describe, expect, it } from "vitest";
import { FromMessage, ToMessage } from "./messages";
import App from "./App";

function sendMessage(data: FromMessage) {
    fireEvent(window, new MessageEvent('message', { data: data }))
}

export function expectNotNull<T>(
    value: T | null
  ): asserts value is T {
    expect(value).not.toBeNull();
}

function Test1() {
    return <>
        <div>Test1</div>
    </>
}

function Test2() {
    return <>
        <div>Test2</div>
        <Test1 />
    </>
}

function Test3() {
    return <>
        <div>Test3</div>
        <Test2 />
    </>
}

function Test4() {
    return <>
        <div>Test4</div>
        <Test3 />
    </>
}

describe('App', () => {
    it('renders App component', () => {
        let receivedMessage = null as ToMessage | null 
        function receiveMessage(message: ToMessage) {
            console.log(JSON.stringify(message))
            receivedMessage = message
        }
        render(<App sendMessage={receiveMessage} />);

        expectNotNull(receivedMessage)
        expect(receivedMessage.type).toBe('uiReady')

        sendMessage({ type: 'hammerspoonReady' })
        screen.debug();
    });

    it('renders nested components', () => {
        render(<Test4 />)
        screen.debug()
    })
});

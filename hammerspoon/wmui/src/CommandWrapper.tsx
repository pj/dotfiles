import React, { useLayoutEffect, useRef, useState } from "react";

export type WrappedCommandResult = {
    inner: React.ReactNode
    next: React.ReactNode | null
    keyHandler: (event: React.KeyboardEvent<HTMLDivElement>) => void
}

export type WrappedCommandGenerate = (additionalProps: AdditionalProps) => WrappedCommandResult

export type WrappedCommandProps = {
    keyPressed: string | null
    focus: boolean
}

export type CommandWrapperProps<AdditionalProps> = {
    index: number,
    testId: string

    generate: WrappedCommandGenerate

    // component: React.ComponentType<WrappedCommandProps & AdditionalProps>
    // additionalProps: AdditionalProps
}

export function CommandWrapper<AdditionalProps>(props: CommandWrapperProps<AdditionalProps>) {
    const wrapperElement = useRef<HTMLDivElement>(null);
    const [keyPressed, setKeyPressed] = useState<string | null>(null)
    const [focus, setFocus] = useState(false)

    useLayoutEffect(() => {
        setFocus(true)
        wrapperElement.current?.focus();
    }, []);

    function handleKeyDown(event: React.KeyboardEvent<HTMLDivElement>) {
        if (event.key === 'Backspace') {
            event.preventDefault()
            return;
        }
        setKeyPressed(event.key)
    }

    return (
            <div
                tabIndex={props.index}
                onClick={() => {
                    setFocus(true)
                    wrapperElement.current?.focus()
                }}
                onBlur={() => {
                    setFocus(false)
                }}
                ref={wrapperElement}
                data-testid={props.testId + '-' + props.index}
                key={props.index}
                className="bg-white rounded-lg p-10 border border-gray-300 shadow-md focus:outline-none focus:ring focus:ring-light-blue-200"
                onKeyDown={handleKeyDown}
            >
                {props.component ? React.createElement(props.component, { keyPressed, focus, ...props.additionalProps }) : <></>}
            </div>
    );
}
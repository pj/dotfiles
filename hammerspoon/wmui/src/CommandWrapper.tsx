import React, { useLayoutEffect, useRef } from "react";

export type CommandWrapperProps = {
    index: number,
    children: React.ReactNode
    onKeyDown?: (event: React.KeyboardEvent<HTMLDivElement>) => void
    onBackspace: () => void
    setFocus: (focus: boolean) => void
    testId: string
}

export function CommandWrapper({ index, children, onKeyDown, onBackspace, setFocus, testId }: CommandWrapperProps) {
    const wrapperElement = useRef<HTMLDivElement>(null);
    
    useLayoutEffect(() => {
        setFocus(true)
        wrapperElement.current?.focus();
    });

    function handleKeyDown(event: React.KeyboardEvent<HTMLDivElement>) {
        if (event.key === 'Backspace') {
            event.preventDefault()
            onBackspace()
            return;
        }
        if (onKeyDown) {
            onKeyDown(event)
        }
    }

    return (
        <div 
            tabIndex={index}
            onClick={() => {
                setFocus(true)
                wrapperElement.current?.focus()
            }}
            onBlur={() => {
                setFocus(false)
            }}
            ref={wrapperElement}
            data-testid={testId + '-' + index}
            key={index} 
            className="bg-white rounded-lg p-10 border border-gray-300 shadow-md focus:outline-none focus:ring focus:ring-light-blue-200" 
            onKeyDown={handleKeyDown}
        >
            {children}
        </div>
    );
}
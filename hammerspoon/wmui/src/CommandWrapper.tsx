import React, { useLayoutEffect, useRef } from "react";

export type CommandWrapperProps = {
    index: number,
    children: React.ReactNode
    onKeyDown?: (event: React.KeyboardEvent<HTMLDivElement>) => void
    testId: string
}

export function CommandWrapper({ index, children, onKeyDown, testId }: CommandWrapperProps) {
    const wrapperElement = useRef<HTMLDivElement>(null);
    
    console.log("rendering")

    useLayoutEffect(() => {
        console.log("focusing")
        wrapperElement.current?.focus();
    });
    return (
        <div 
            tabIndex={index}
            onClick={() => {
                console.log("setting focus")
                wrapperElement.current?.focus()
            }}
            ref={wrapperElement}
            data-testid={testId + '-' + index}
            key={index} 
            className="bg-white rounded-lg p-10 border border-gray-300 shadow-md focus:outline-none focus:ring focus:ring-light-blue-200" 
            onKeyDown={onKeyDown}
        >
            {children}
        </div>
    );
}
import React, { useLayoutEffect, useRef, useState } from "react";

export type DefaultCommandProps = {
    index: number,
    handleDelete: () => void,
}

export type CommandWrapperProps = DefaultCommandProps & {
    testId: string,
    inner: React.ReactNode
    next: React.ReactNode | null
    keyHandler: (event: React.KeyboardEvent<HTMLDivElement>) => void
}

type Focus = {
    wrapperElement: React.RefObject<HTMLDivElement>,
    focus: boolean,
    setFocus: (focus: boolean) => void
}

export function useFocus(): Focus {
    const wrapperElement = useRef<HTMLDivElement>(null);
    const [focus, setFocus] = useState(true)

    useLayoutEffect(() => {
        if (focus) {
            wrapperElement.current?.focus();
        } else {
            wrapperElement.current?.blur();
        }
    }, [focus]);

    return { wrapperElement, focus, setFocus }
}

export function defaultCommandProps(index: number, testId: string, wrapperElement: React.RefObject<HTMLDivElement>, setFocus: (focus: boolean) => void) {
    return {
        tabIndex: index,
        ref: wrapperElement,
        "data-testid": testId + '-' + index,
        className: "card card-bordered bg-white shadow-md border-gray-300 focus:outline-none focus:ring focus:ring-light-blue-200",
        onClick: (event: React.MouseEvent<HTMLDivElement>) => {
            if (event.target instanceof HTMLInputElement || event.target instanceof HTMLSelectElement) {
                return; // Let the input handle the event naturally
            }
            setFocus(true)
        },
        onBlur: () => setFocus(false)
    }
}
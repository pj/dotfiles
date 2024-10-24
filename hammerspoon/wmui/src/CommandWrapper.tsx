import React, { useLayoutEffect, useRef, useState } from "react";
import { ToMessage } from "./messages";

export type DefaultCommandProps = {
    index: number,
    handleDelete: () => void,
    sendMessage: (message: ToMessage) => void
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
        key: index,
        className: "bg-white rounded-lg p-10 border border-gray-300 shadow-md focus:outline-none focus:ring focus:ring-light-blue-200",
        onClick: () => setFocus(true),
        onBlur: () => setFocus(false)
    }
}
// export function CommandWrapper(props: CommandWrapperProps) {
//     const wrapperElement = useRef<HTMLDivElement>(null);
//     const [focus, setFocus] = useState(true)

//     useLayoutEffect(() => {
//         if (focus) {
//             wrapperElement.current?.focus();
//         } else {
//             wrapperElement.current?.blur();
//         }
//     }, [focus]);

//     return (
//         <>
//             <div
//                 tabIndex={props.index}
//                 onClick={() => {
//                     setFocus(true)
//                 }}
//                 onBlur={() => {
//                     setFocus(false)
//                 }}
//                 ref={wrapperElement}
//                 data-testid={props.testId + '-' + props.index}
//                 key={props.index}
//                 className="bg-white rounded-lg p-10 border border-gray-300 shadow-md focus:outline-none focus:ring focus:ring-light-blue-200"
//                 onKeyDown={props.keyHandler}
//             >
//                 {props.inner}
//             </div>
//             {props.next}
//         </>
//     );
// }
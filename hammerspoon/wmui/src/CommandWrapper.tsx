import React, { useLayoutEffect, useRef, useState } from "react";

export type WrappedCommandGenerateResult = {
    inner: React.ReactNode
    next: React.ReactNode | null
    keyHandler: (event: React.KeyboardEvent<HTMLDivElement>) => void
}

export type WrappedCommandGenerateProps = {
    focus: boolean
    index: number
    handleDelete: () => void
}

export type WrappedCommandGenerate<AdditionalProps> =
    (additionalProps: WrappedCommandGenerateProps & AdditionalProps) => WrappedCommandGenerateResult

export type DefaultCommandProps = {
    index: number,
    testId: string,
    handleDelete: () => void
}

export type CommandWrapperProps<AdditionalProps> = DefaultCommandProps & {
    generate: WrappedCommandGenerate<AdditionalProps>
    additionalProps: AdditionalProps
}

export function CommandWrapper<AdditionalProps>(props: CommandWrapperProps<AdditionalProps>) {
    const wrapperElement = useRef<HTMLDivElement>(null);
    const [focus, setFocus] = useState(true)

    useLayoutEffect(() => {
        console.log(`${props.testId}-${props.index} focus: ${focus}`)
        if (focus) {
            wrapperElement.current?.focus();
        } else {
            wrapperElement.current?.blur();
        }
    }, [focus]);

    function handleDelete() {
        props.handleDelete()
        setFocus(true)
    }

    const { inner, next, keyHandler } = props.generate({ focus, handleDelete, ...props.additionalProps, index: props.index + 1 })

    return (
        <>
            <div
                tabIndex={props.index}
                onClick={() => {
                    setFocus(true)
                }}
                onBlur={() => {
                    setFocus(false)
                }}
                ref={wrapperElement}
                data-testid={props.testId + '-' + props.index}
                key={props.index}
                className="bg-white rounded-lg p-10 border border-gray-300 shadow-md focus:outline-none focus:ring focus:ring-light-blue-200"
                onKeyDown={keyHandler}
            >
                {inner}
            </div>
            {next}
        </>
    );
}
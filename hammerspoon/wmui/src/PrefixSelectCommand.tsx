import { useState } from "react"
import { defaultCommandProps, DefaultCommandProps, useFocus } from "./CommandWrapper"
import { ToMessage } from "./messages"
import React from "react"

type Prefix = {
    component: React.ComponentType<any>
    props: any
    description: string
}

type PrefixMap = Map<string, Prefix>

export type PrefixSelectCommandProps = DefaultCommandProps & {
    prefixes: PrefixMap
    sendMessage: (message: ToMessage) => void
}

export function PrefixSelectCommand(props: PrefixSelectCommandProps) {
    const { wrapperElement, setFocus } = useFocus()
    const [selectedKey, setSelectedKey] = useState<string | null>(null)

    const prefixList = []

    for (const [prefix, { description }] of props.prefixes.entries()) {
        prefixList.push(<div key={prefix}>{prefix}: {description}</div>)
    }

    let selectedComponent = null
    let selectedProps = null
    if (selectedKey) {
        const prefix = props.prefixes.get(selectedKey)
        if (prefix) {
            selectedComponent = prefix.component
            selectedProps = prefix.props
        }
    }

    function handleKey(event: React.KeyboardEvent<HTMLDivElement>) {
        event.preventDefault()
        if (event.key === 'Backspace') {
            props.handleDelete()
            return;
        }
        setSelectedKey(event.key)
    }

    function handleDelete() {
        setSelectedKey(null)
        setFocus(true)
    }

    return (<>
        <div
            onKeyDown={handleKey}
            {...defaultCommandProps(props.index, "prefix-select-command", wrapperElement, setFocus)}
        >
            {prefixList}
        </div>
        {selectedComponent ? React.createElement(selectedComponent, { index: props.index + 1, handleDelete, ...selectedProps }) : null}
    </>)
}

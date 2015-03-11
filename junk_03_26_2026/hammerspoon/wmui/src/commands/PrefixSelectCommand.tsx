import { useContext, useEffect, useState } from "react"
import { defaultCommandProps, DefaultCommandProps, useFocus } from "../CommandWrapper"
import React from "react"
import { AppExitContext } from "../App"
import { Key } from "../Key"

export type Prefix = {
    type: "command"
    component: React.ComponentType<any>
    props: any
    description: string
} | {
    type: "quickFunction"
    description: string
    quickFunction: () => void
}

type PrefixMap = Map<string, Prefix>

export type PrefixSelectCommandProps = DefaultCommandProps & {
    prefixes: PrefixMap
}

export function PrefixSelectCommand(props: PrefixSelectCommandProps) {
    const handleExit = useContext(AppExitContext)
    const { wrapperElement, setFocus } = useFocus()
    const [selectedKey, setSelectedKey] = useState<string | null>(null)

    const prefixList = []

    for (const [prefix, { description }] of props.prefixes.entries()) {
        prefixList.push(<div key={prefix} className="flex flex-row items-center gap-2">
            <Key key={prefix} text={prefix}/> <span className="text-md text-gray-600">{description}</span>
        </div>)
    }

    let selectedComponent = null
    let selectedProps = null
    if (selectedKey) {
        const prefix = props.prefixes.get(selectedKey)
        if (prefix && prefix.type === "command") {
            selectedComponent = prefix.component
            selectedProps = prefix.props
        }
    }

    function handleKey(event: React.KeyboardEvent<HTMLDivElement>) {
        event.preventDefault()
        if (event.key === 'Escape') {
            handleExit()
            return;
        }
        if (event.key === 'Backspace') {
            props.handleDelete()
            return;
        }
        setSelectedKey(event.key)
    }

    useEffect(() => {
        if (selectedKey) {
            const prefix = props.prefixes.get(selectedKey)
            if (prefix && prefix.type === "quickFunction") {
                prefix.quickFunction()
                handleExit();
            }
        }
    }, [selectedKey])

    function handleDelete() {
        setSelectedKey(null)
        setFocus(true)
    }

    return (<>
        <div
            key={props.index}
            {...defaultCommandProps(props.index, "prefix-select-command", wrapperElement, setFocus)}
            onKeyDown={handleKey}
        >
            <div className="text-xs text-center text-gray-600">Select</div>
            <hr className="border-gray-300"/>
            <div className="card-body">
                {prefixList}
            </div>
        </div>
        {selectedComponent ? React.createElement(selectedComponent, { index: props.index + 1, handleDelete, ...selectedProps }) : null}
    </>);
}

import { useState } from "react"
import { CommandWrapper } from "./CommandWrapper"
import { ToMessage } from "./messages"
import React from "react"

export type PrefixSelectCommandProps = {
    prefixes: Map<string, [React.ComponentType<any>, string]>
    index: number
    sendMessage: (message: ToMessage) => void
}

export function PrefixSelectCommand({ prefixes, index }: PrefixSelectCommandProps) {
    const [selectedKey, setSelectedKey] = useState<string | null>(null)

    const handleKeyDown = (event: React.KeyboardEvent<HTMLDivElement>) => {
        const prefix = prefixes.get(event.key)
        if (prefix) {
            setSelectedKey(event.key)
        }
    }

    const prefixList = []

    for (const [prefix, [_, description]] of prefixes.entries()) {
        prefixList.push(<div key={prefix}>{prefix}: {description}</div>)
    }

    let selectedComponent = null
    if (selectedKey) {
        const prefix = prefixes.get(selectedKey)
        if (prefix) {
            selectedComponent = prefix[0]
        }
    }

    return <>
        <CommandWrapper 
            index={index} 
            onKeyDown={handleKeyDown} 
            testId="prefix-select-command" 
            onBackspace={() => setSelectedKey(null)} 
        >
            {prefixList}
        </CommandWrapper>
        {selectedComponent ? React.createElement(selectedComponent, { index: index + 1 }) : <></>}
    </>;
}

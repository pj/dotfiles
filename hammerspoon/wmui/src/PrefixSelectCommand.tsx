import { useState } from "react"
import { CommandWrapper, DefaultCommandProps, WrappedCommandGenerateProps } from "./CommandWrapper"
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

type prefixCommandGenerateProps = WrappedCommandGenerateProps & {
    prefixes: PrefixMap
}

function prefixCommandGenerate( props: prefixCommandGenerateProps) {
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

    function handleDelete() {
        setSelectedKey(null)
        props.handleDelete()
    }

    return {
        inner: <>{prefixList}</>,
        next: selectedComponent ? React.createElement(selectedComponent, { index: props.index, handleDelete,...selectedProps }) : null,
        keyHandler: (event: React.KeyboardEvent<HTMLDivElement>) => {
            event.preventDefault()
            if (event.key === 'Backspace') {
                setSelectedKey(null)
                return;
            }
            setSelectedKey(event.key)
        }
    }
}

export function PrefixSelectCommand({ prefixes, index, handleDelete }: PrefixSelectCommandProps) {

    return <>
        <CommandWrapper 
            index={index} 
            testId="prefix-select-command" 
            generate={prefixCommandGenerate}
            additionalProps={{
                prefixes,
            }}
            handleDelete={handleDelete}
        />
    </>;
}

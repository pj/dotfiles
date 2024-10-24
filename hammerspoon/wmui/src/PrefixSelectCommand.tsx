import { useEffect, useState } from "react"
import { CommandWrapper, WrappedCommandProps } from "./CommandWrapper"
import { ToMessage } from "./messages"
import React from "react"

type Prefix = {
    component: React.ComponentType<any>
    props: any
    description: string
}

type PrefixMap = Map<string, Prefix>

export type PrefixSelectCommandProps = {
    prefixes: PrefixMap
    index: number
    sendMessage: (message: ToMessage) => void
}

type InnerPrefixSelectCommandProps = WrappedCommandProps & {
    prefixes: PrefixMap
    setSelectedKey: (key: string | null) => void
}

function InnerPrefixSelectCommand({ keyPressed: key, prefixes, setSelectedKey }: InnerPrefixSelectCommandProps) {
    useEffect(() => {
        setSelectedKey(key)
    }, [key])

    const prefixList = []

    for (const [prefix, { description }] of prefixes.entries()) {
        prefixList.push(<div key={prefix}>{prefix}: {description}</div>)
    }

    return <>{prefixList}</>
}

export function PrefixSelectCommand({ prefixes, index }: PrefixSelectCommandProps) {
    return <>
        <CommandWrapper 
            index={index} 
            testId="prefix-select-command" 
            component={InnerPrefixSelectCommand}
            additionalProps={{
                prefixes,
            }}
        />
    </>;
}

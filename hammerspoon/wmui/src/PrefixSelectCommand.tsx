import { useState } from "react"
import { CommandWrapper } from "./CommandWrapper"
import { ToMessage } from "./messages"

export type PrefixSelectCommandProps = {
  prefixes: Map<string, [React.ComponentType<any>, string]>
  index: number
  sendMessage: (message: ToMessage) => void
}

export function PrefixSelectCommand({ prefixes, index }: PrefixSelectCommandProps) {
  const [selectedPrefix, setSelectedPrefix] = useState<string | null>(null)

  const handleKeyDown = (event: React.KeyboardEvent<HTMLDivElement>) => {
    console.log("here")
    setSelectedPrefix(event.key)
  }

  const prefixList = []

  for (const [prefix, [_, description]] of prefixes.entries()) {
    prefixList.push(<div key={prefix}>{prefix}: {description}</div>)
  }

  return <>
    <CommandWrapper index={index} onKeyDown={handleKeyDown} testId="prefix-select-command">
      {prefixList}
    </CommandWrapper>
    {selectedPrefix && prefixes.get(selectedPrefix)}
  </>;
}

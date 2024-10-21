// import { ActionReturn, Command } from "./command_interpreter"
import { useState } from "react"
// import { sendMessage } from "./messages"

export type VolumeCommandProps = {
  prefixes: Map<string, [React.ComponentType<any>, string]>
  index: number
}

export function VolumeCommand({ prefixes, index }: VolumeCommandProps) {
  const [selectedPrefix, setSelectedPrefix] = useState<string | null>(null)

  const handleKeyDown = (event: React.KeyboardEvent<HTMLDivElement>) => {
    setSelectedPrefix(event.key)
  }

  const prefixList = []

  for (const [prefix, [_, description]] of prefixes.entries()) {
    prefixList.push(<div key={prefix}>{prefix}: {description}</div>)
  }

  return <>
    <div key={index} onKeyDown={handleKeyDown}>
      {prefixList}
    </div>
    {selectedPrefix && prefixes.get(selectedPrefix)?.[0]}
  </>;
}

// export class PrefixCommand {
//   action(key: string | null): ActionReturn {
//     if (key === null) {
//       return ['continue', []]
//     }

//     const command = this.prefixes.get(key)
//     if (command) {
//       const [result, nextWidgets] = command.action(key)
//       return [result, nextWidgets]
//     }

//     return ['key_not_recognized', []]
//   }

//   prefixes: Map<string, Command>

//   constructor(prefixes: Map<string, Command>) {
//     this.prefixes = prefixes
//   }
// }

// export class VolumeChangeCommand {
//   action(key: string | null): ActionReturn {
//     if (key === null) {
//       return ['continue', []]
//     }

//     switch (key) {
//       case 'm':
//         sendMessage({
//           type: 'volumeMute',
//         })
//         return ['completed', []]
//       case 'Enter':
//         return ['completed', []]
//       case '+':
//         sendMessage({
//           type: 'volumeUp',
//         })
//         return ['continue', []]
//       case '-':
//         sendMessage({
//           type: 'volumeDown',
//         })
//         return ['continue', []]
//       case "ArrowUp":
//         sendMessage({
//           type: 'volumeUp',
//         })
//         return ['continue', []]
//       case "ArrowDown":
//         sendMessage({
//           type: 'volumeDown',
//         })
//         return ['continue', []]
//     }

//     return ['key_not_recognized', []]
//   }
// }

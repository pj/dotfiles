// import { ActionReturn, Command } from "./command_interpreter"
import { sendMessage } from "./messages"

export function CommandWrapper() {

}

export function PrefixSelectCommand() {

  return 
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

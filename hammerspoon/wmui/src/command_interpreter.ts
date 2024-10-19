// import { useState } from "react"

// export type Widget = React.FunctionComponent<any>

// export type ActionReturn = Command | 'continue' | 'completed' | 'end' | 'key_not_recognized'

// export type CommandInput = {type: 'start', context: any} | {type: 'key', key: string, context: any} | {type: 'changed', context: any}

// export interface Command {
//     action: (input: CommandInput) => ActionReturn
//     widget: (active: boolean) => React.ReactNode
// }

// // export class CommandInterpreter {
// //     private currentCommand: Command
// //     private previousCommands: Command[]
// //     private previousWidgets: Widget[]

// //     constructor(command: Command) {
// //         this.currentCommand = command
// //         this.previousCommands = []
// //         this.previousWidgets = []
// //     }

// //     key(key: string): [Widget[], 'completed' | 'key_not_recognized' | 'continue'] {
// //         const [nextCommand, widgets] = this.currentCommand.action(key)
// //         const nextWidgets = [...this.previousWidgets, ...widgets]
// //         if (nextCommand === 'completed') {
// //             this.previousCommands.push(this.currentCommand)
// //             return [nextWidgets, 'completed']
// //         } else if (nextCommand === 'key_not_recognized') {
// //             return [nextWidgets, 'key_not_recognized']
// //         } else if (nextCommand === 'continue') {
// //             return [nextWidgets, 'continue']
// //         } else {
// //             this.currentCommand = nextCommand
// //             return [nextWidgets, 'continue']
// //         }
// //     }
// // }

// export type CommandInterpreterProps = {rootCommand: Command, endInterpreter: () => void, keyNotRecognized: (key: string) => void}

// export function CommandInterpreter(props: CommandInterpreterProps) {
//     const [commandStack, setCommandStack] = useState<Command[]>([props.rootCommand])

//     function addToStack(command: Command) {
//         setCommandStack([...commandStack, command])
//     }

//     function resetStack(index: number) {
//       setCommandStack(commandStack.slice(0, index))
//     }

//     function sendKey(key: string) {
//       const currentCommand = commandStack[commandStack.length - 1]
//       const nextCommand = currentCommand.action({type: 'key', key})
//       if (nextCommand === 'completed') {
//       } else if (nextCommand === 'end') {
//         props.endInterpreter()
//       } else if (nextCommand === 'key_not_recognized') {
//       } else if (nextCommand !== 'continue') {
//         addToStack(nextCommand)
//       }
//     }

//     return [
//       sendKey
//     ]
// }

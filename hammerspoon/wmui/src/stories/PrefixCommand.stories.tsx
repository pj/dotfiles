import type { Meta, StoryObj } from '@storybook/react';
import React from 'react';

import { TextCommand } from '../NullCommand';
import { PrefixSelectCommand } from '../PrefixSelectCommand';
import App from '../App';
import { FromMessage, ToMessage } from '../messages';
import { expect, userEvent, waitFor, within } from '@storybook/test';

const meta = {
    title: 'PrefixCommand',
    component: PrefixSelectCommand,
    tags: ['autodocs'],
    parameters: {
        layout: 'centered',
    },
} satisfies Meta<typeof PrefixSelectCommand>;

export default meta;
type Story = StoryObj<typeof meta>;

export const Selected: Story = {
    parameters: {
        commandMessaging: {
            lastReceivedMessage: null,
            lastReceivedMessages: [],
            onMessage: null
        },
    },
    decorators: [
        (Command, { args, parameters }) => {
            let receiveMessage = (msg: ToMessage) => {
                parameters.commandMessaging.lastReceivedMessage = msg
                parameters.commandMessaging.lastReceivedMessages.push(msg)
            }

            parameters.commandMessaging.sendMessage = (msg: FromMessage) => {
                parameters.commandMessaging.onMessage(
                    new MessageEvent('message', { data: msg })
                )   
            }

            return (
                <App
                    RootCommand={Command}
                    RootCommandProps={{
                        prefixes: args.prefixes,
                        index: args.index
                    }}
                    sendMessage={receiveMessage}
                    setEventListener={onMessage => parameters.commandMessaging.onMessage = onMessage}
                    removeEventListener={_ => parameters.commandMessaging.onMessage = null}
                />
            )
        },
    ],
    play: async ({ canvasElement, parameters }) => {
      const canvas = within(canvasElement)
      
      parameters.commandMessaging.sendMessage({ type: 'hammerspoonReady' })

      expect(parameters.commandMessaging.lastReceivedMessages[0]).toEqual({ type: 'uiReady' })
      expect(parameters.commandMessaging.lastReceivedMessages[1]).toEqual({ type: 'log', log: 'received message: {"type":"hammerspoonReady"}' })

      await waitFor(() => {
        expect(canvas.queryByTestId('app-loading')).not.toBeInTheDocument()
      })

      const prefixSelectCommand = canvas.getByTestId('prefix-select-command-0')
      expect(prefixSelectCommand).toBeInTheDocument()

      await waitFor(() => {
        expect(prefixSelectCommand).toHaveFocus()
      })

      await userEvent.type(prefixSelectCommand, 'n')
    },
    args: {
        prefixes: new Map(
            [
                [
                    'n', 
                    {
                        component: TextCommand, 
                        props: {
                            text: "Hello World!", 
                        }, 
                        description: 'Null'
                    }
                ]
            ]
        ),
        index: 0,
        testId: 'prefix-select-command',
        sendMessage: (msg: ToMessage) => { },
        handleDelete: () => { console.log('top level handleDelete')}
    },
};
export const Backspaced: Story = {
    parameters: {
        commandMessaging: {
            lastReceivedMessage: null,
            lastReceivedMessages: [],
            onMessage: null
        },
    },
    decorators: [
        (Command, { args, parameters }) => {
            let receiveMessage = (msg: ToMessage) => {
                parameters.commandMessaging.lastReceivedMessage = msg
                parameters.commandMessaging.lastReceivedMessages.push(msg)
            }

            parameters.commandMessaging.sendMessage = (msg: FromMessage) => {
                parameters.commandMessaging.onMessage(
                    new MessageEvent('message', { data: msg })
                )   
            }

            return (
                <App
                    RootCommand={Command}
                    RootCommandProps={{
                        prefixes: args.prefixes,
                        index: args.index,
                        testId: args.testId,
                        handleDelete: args.handleDelete
                    }}
                    sendMessage={receiveMessage}
                    setEventListener={onMessage => parameters.commandMessaging.onMessage = onMessage}
                    removeEventListener={_ => parameters.commandMessaging.onMessage = null}
                />
            )
        },
    ],
    play: async ({ canvasElement, parameters }) => {
      const canvas = within(canvasElement)
      
      parameters.commandMessaging.sendMessage({ type: 'hammerspoonReady' })

      expect(parameters.commandMessaging.lastReceivedMessages[0]).toEqual({ type: 'uiReady' })
      expect(parameters.commandMessaging.lastReceivedMessages[1]).toEqual({ type: 'log', log: 'received message: {"type":"hammerspoonReady"}' })

      await waitFor(() => {
        expect(canvas.queryByTestId('app-loading')).not.toBeInTheDocument()
      })

      const prefixSelectCommand = canvas.getByTestId('prefix-select-command-0')
      expect(prefixSelectCommand).toBeInTheDocument()

      await waitFor(() => {
        expect(prefixSelectCommand).toHaveFocus()
      })

      await userEvent.type(prefixSelectCommand, 'n')
      await userEvent.type(prefixSelectCommand, '{backspace}')
    },
    args: {
        prefixes: new Map(
            [
                [
                    'n', 
                    {
                        component: TextCommand, 
                        props: {
                            text: "Hello World!", 
                        }, 
                        description: 'Null'
                    }
                ]
            ]
        ),
        index: 0,
        testId: 'prefix-select-command',
        sendMessage: (msg: ToMessage) => { },
        handleDelete: () => { console.log('top level handleDelete')}
    },
};

// export const NotSelected: Story = {

//   args: {
//     RootCommand: PrefixSelectCommand,
//     RootCommandProps: {
//       prefixes: new Map([
//         ['n', [NullCommand, 'Null'] as [React.ComponentType<any>, string]],
//       ]),
//     },
//     sendMessage: (msg: ToMessage) => { }
//   },
// };

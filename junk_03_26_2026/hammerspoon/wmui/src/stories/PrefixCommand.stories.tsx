import type { Meta, StoryObj } from '@storybook/react';

import { TextCommand } from '../commands/TextCommand';
import { PrefixSelectCommand } from '../commands/PrefixSelectCommand';
import { expect, userEvent, waitFor, within } from '@storybook/test';
import { CommandDecorator } from './CommandDecorator';
import { hammerspoonReady } from './utils';

const meta = {
    title: 'PrefixCommand',
    component: PrefixSelectCommand,
    tags: ['autodocs'],
    parameters: {
        backgrounds: {
            grid: {
              cellSize: 20,
              opacity: 0.5,
              cellAmount: 5,
              offsetX: 16, // Default is 0 if story has 'fullscreen' layout, 16 if layout is 'padded'
              offsetY: 16, // Default is 0 if story has 'fullscreen' layout, 16 if layout is 'padded'
            },
          },
        layout: 'centered',
        commandMessaging: {
            lastReceivedMessage: null,
            lastReceivedMessages: [],
            onMessage: null
        },
    },
    decorators: [
        CommandDecorator,
    ],
    args: {
        prefixes: new Map(
            [
                [
                    'H',
                    {
                        type: "command",
                        component: TextCommand,
                        props: {
                            text: "Hello World!",
                        },
                        description: 'Hello World'
                    }
                ]
            ]
        ),
        index: 0,
        handleDelete: () => { },
    },
} satisfies Meta<typeof PrefixSelectCommand>;

export default meta;
type Story = StoryObj<typeof meta>;

export const Setup: Story = {
    play: async ({ canvasElement, parameters }) => {
        const canvas = await hammerspoonReady(canvasElement, parameters)

        const prefixSelectCommand = canvas.getByTestId('prefix-select-command-0')
        expect(prefixSelectCommand).toBeInTheDocument()

        await waitFor(() => {
            expect(prefixSelectCommand).toHaveFocus()
        })
    },
}

export const Selected: Story = {
    play: async (playContext) => {
        const canvas = within(playContext.canvasElement)

        await Setup.play?.(playContext)

        const prefixSelectCommand = canvas.getByTestId('prefix-select-command-0')
        await userEvent.type(prefixSelectCommand, 'n')

        const textCommand = canvas.getByTestId('text-command-1')
        expect(textCommand).toBeInTheDocument()
        await waitFor(() => {
            expect(textCommand).toHaveFocus()
        })
    },
};

export const Backspaced: Story = {
    play: async (playContext) => {
        const canvas = within(playContext.canvasElement)

        await Setup.play?.(playContext)

        const prefixSelectCommand = canvas.getByTestId('prefix-select-command-0')
        await userEvent.type(prefixSelectCommand, 'n')

        const textCommand = canvas.getByTestId('text-command-1')
        expect(textCommand).toBeInTheDocument()
        await userEvent.type(textCommand, '{backspace}')

        await waitFor(() => {
            expect(canvas.queryByTestId('text-command-1')).not.toBeInTheDocument()
        })

        await waitFor(() => {
            expect(prefixSelectCommand).toHaveFocus()
        })
    },
};

import type { Meta, StoryObj } from '@storybook/react';

import { expect, userEvent, waitFor, within } from '@storybook/test';
import { CommandDecorator } from './CommandDecorator';
import { hammerspoonReady } from './utils';
import { LockCommand } from '../commands/LockCommand';

const meta = {
    title: 'LockCommand',
    component: LockCommand,
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
        index: 0,
        handleDelete: () => { },
    },
} satisfies Meta<typeof LockCommand>;

export default meta;
type Story = StoryObj<typeof meta>;

export const Setup: Story = {
    play: async ({ canvasElement, parameters }) => {
        const canvas = await hammerspoonReady(canvasElement, parameters)

        const volumeCommand = canvas.getByTestId('lock-command-0')
        expect(volumeCommand).toBeInTheDocument()

        await waitFor(() => {
            expect(volumeCommand).toHaveFocus()
        })
    },
}

export const LockScreen: Story = {
    play: async (playContext) => {
        const canvas = within(playContext.canvasElement)

        await Setup.play?.(playContext)

        const lockButton = canvas.getByTestId('lock-button-0')
        await userEvent.click(lockButton)

        expect(
            playContext.parameters.commandMessaging.lastReceivedMessages[
                playContext.parameters.commandMessaging.lastReceivedMessages.length - 1
            ]
        ).toEqual({ type: 'lockScreen' })
    },
};

import type { Meta, StoryObj } from '@storybook/react';

import { expect, userEvent, waitFor, within } from '@storybook/test';
import { CommandDecorator } from './CommandDecorator';
import { hammerspoonReady } from './utils';
import { VolumeCommand } from '../commands/VolumeCommand';

const meta = {
    title: 'VolumeCommand',
    component: VolumeCommand,
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
} satisfies Meta<typeof VolumeCommand>;

export default meta;
type Story = StoryObj<typeof meta>;

export const Loading: Story = {
    play: async ({ canvasElement, parameters }) => {
        const canvas = await hammerspoonReady(canvasElement, parameters)

        const volumeCommand = canvas.getByTestId('volume-command-0')
        expect(volumeCommand).toBeInTheDocument()

        await waitFor(() => {
            expect(volumeCommand).toHaveFocus()
        })

        const volumeLoading = canvas.getByTestId('volume-loading')
        expect(volumeLoading).toBeInTheDocument()
    },
}

export const Muted: Story = {
    play: async (playContext) => {
        // const canvas = within(playContext.canvasElement)

        await Loading.play?.(playContext)

        playContext.parameters.commandMessaging.sendMessage({ type: 'volume', muted: true, volume: 49 })

        // const volumeCommand = canvas.getByTestId('volume-command-0')

        // await waitFor(() => {
        //     expect(volumeCommand.textContent).toMatch(/Muted/)
        // })
    },
};

export const Unmuted: Story = {
    play: async (playContext) => {
        // const canvas = within(playContext.canvasElement)

        await Loading.play?.(playContext)

        playContext.parameters.commandMessaging.sendMessage({ type: 'volume', muted: false, volume: 49 })

        // const volumeCommand = canvas.getByTestId('volume-command-0')

        // await waitFor(() => {
        //     expect(volumeCommand.textContent).toMatch(/Muted/)
        // })
    },
};

export const VolumeUp: Story = {
    play: async (playContext) => {
        const canvas = within(playContext.canvasElement)

        await Loading.play?.(playContext)

        playContext.parameters.commandMessaging.sendMessage({ type: 'volume', muted: false, volume: 49 })

        const volumeCommand = canvas.getByTestId('volume-command-0')

        await userEvent.type(volumeCommand, 'u')

        playContext.parameters.commandMessaging.sendMessage({ type: 'volume', muted: false, volume: 90 })

        // await waitFor(() => {
        //     expect(volumeCommand.textContent).toMatch(/Muted/)
        // })
    },
};

export const VolumeClickUp: Story = {
    play: async (playContext) => {
        const canvas = within(playContext.canvasElement)

        await Loading.play?.(playContext)

        playContext.parameters.commandMessaging.sendMessage({ type: 'volume', muted: false, volume: 49 })

        await waitFor(() => {
            expect(canvas.getByTestId('volume-up-0')).toBeInTheDocument()
        })

        const volumeUpButton = canvas.getByTestId('volume-up-0')
        await userEvent.click(volumeUpButton)

        playContext.parameters.commandMessaging.sendMessage({ type: 'volume', muted: false, volume: 90 })

        // await waitFor(() => {
        //     expect(volumeCommand.textContent).toMatch(/Muted/)
        // })
    },
};

export const VolumeDown: Story = {
    play: async (playContext) => {
        const canvas = within(playContext.canvasElement)

        await Loading.play?.(playContext)

        playContext.parameters.commandMessaging.sendMessage({ type: 'volume', muted: false, volume: 49 })

        const volumeCommand = canvas.getByTestId('volume-command-0')

        await userEvent.type(volumeCommand, 'd')

        playContext.parameters.commandMessaging.sendMessage({ type: 'volume', muted: false, volume: 25 })

        // await waitFor(() => {
        //     expect(volumeCommand.textContent).toMatch(/Muted/)
        // })
    },
};

export const VolumeSet: Story = {
    play: async (playContext) => {
        const canvas = within(playContext.canvasElement)

        await Loading.play?.(playContext)

        playContext.parameters.commandMessaging.sendMessage({ type: 'volume', muted: false, volume: 49 })

        const volumeCommand = canvas.getByTestId('volume-command-0')

        await userEvent.type(volumeCommand, 'd')

        playContext.parameters.commandMessaging.sendMessage({ type: 'volume', muted: false, volume: 25 })

        // await waitFor(() => {
        //     expect(volumeCommand.textContent).toMatch(/Muted/)
        // })
    },
};

export const Mute: Story = {
    play: async (playContext) => {
        const canvas = within(playContext.canvasElement)

        await Loading.play?.(playContext)

        playContext.parameters.commandMessaging.sendMessage({ type: 'volume', muted: false, volume: 49 })

        const volumeCommand = canvas.getByTestId('volume-command-0')

        await userEvent.type(volumeCommand, 'm')

        playContext.parameters.commandMessaging.sendMessage({ type: 'volume', muted: true, volume: 49 })

        // await waitFor(() => {
        //     expect(volumeCommand.textContent).toMatch(/Muted/)
        // })
    },
};

// export const Unmuted: Story = {
//     play: async (playContext) => {
//         const canvas = within(playContext.canvasElement)

//         await ViewTimeLeft.play?.(playContext)
//         playContext.parameters.commandMessaging.sendMessage({
//             type: 'siteBlocker',
//             blocked: true,
//             timeSpent: 0,
//             timeLimit: 60,
//             validTime: true
//         })

//         const siteBlockerCommand = canvas.getByTestId('site-blocker-command-0')
//         await userEvent.type(siteBlockerCommand, 'b')
//         expect(
//             playContext.parameters.commandMessaging.lastReceivedMessages[playContext.parameters.commandMessaging.lastReceivedMessages.length - 1]
//         ).toEqual({ type: 'siteBlocker' })

//         playContext.parameters.commandMessaging.sendMessage({
//             type: 'siteBlocker',
//             blocked: false,
//             timeSpent: 2,
//             timeLimit: 60,
//             validTime: true
//         })

//         await waitFor(() => {
//             expect(siteBlockerCommand.textContent).toMatch(/58 Minutes Left/)
//         })
//     },
// };

// export const StopAvailable: Story = {
//     play: async (playContext) => {
//         const canvas = within(playContext.canvasElement)

//         await StartAvailable.play?.(playContext)

//         const siteBlockerCommand = canvas.getByTestId('site-blocker-command-0')
//         playContext.parameters.commandMessaging.sendMessage({ type: 'siteBlocker', blocked: false, timeSpent: 1, timeLimit: 60, validTime: true })
//         await userEvent.type(siteBlockerCommand, 'b')

//         console.log(playContext.parameters.commandMessaging.lastReceivedMessages)
//         expect(
//             playContext.parameters.commandMessaging.lastReceivedMessages[playContext.parameters.commandMessaging.lastReceivedMessages.length - 1]
//         ).toEqual({ type: 'siteBlocker' })

//         playContext.parameters.commandMessaging.sendMessage({ type: 'siteBlocker', blocked: true, timeSpent: 2, timeLimit: 60, validTime: true })
//         await waitFor(() => {
//             expect(siteBlockerCommand.textContent).toMatch(/58 Minutes Left/)
//         })
//     },
// };

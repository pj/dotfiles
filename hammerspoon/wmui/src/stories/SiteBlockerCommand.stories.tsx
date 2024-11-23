import type { Meta, StoryObj } from '@storybook/react';

import { SiteBlockerCommand } from '../commands/SiteBlocker';
import { expect, userEvent, waitFor, within } from '@storybook/test';
import { CommandDecorator } from './CommandDecorator';
import { hammerspoonReady } from './utils';

const meta = {
    title: 'SiteBlockerCommand',
    component: SiteBlockerCommand,
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
} satisfies Meta<typeof SiteBlockerCommand>;

export default meta;
type Story = StoryObj<typeof meta>;

export const Loading: Story = {
    play: async ({ canvasElement, parameters }) => {
        const canvas = await hammerspoonReady(canvasElement, parameters)

        const siteBlockerCommand = canvas.getByTestId('site-blocker-command-0')
        expect(siteBlockerCommand).toBeInTheDocument()

        await waitFor(() => {
            expect(siteBlockerCommand).toHaveFocus()
        })

        const siteBlockerLoading = canvas.getByTestId('site-blocker-loading')
        expect(siteBlockerLoading).toBeInTheDocument()
    },
}

export const InvalidTime: Story = {
    play: async (playContext) => {
        const canvas = within(playContext.canvasElement)

        await Loading.play?.(playContext)

        playContext.parameters.commandMessaging.sendMessage({ type: 'siteBlocker', blocked: false, timeSpent: 0, timeLimit: 60, validTime: false })
        const siteBlockerCommand = canvas.getByTestId('site-blocker-command-0')

        await waitFor(() => {
            expect(siteBlockerCommand.textContent).toMatch(/60 Minutes Left/)
        })
    },
};

export const InvalidTimeErrorMessage: Story = {
    play: async (playContext) => {
        const canvas = within(playContext.canvasElement)

        await Loading.play?.(playContext)

        playContext.parameters.commandMessaging.sendMessage({ type: 'siteBlocker', blocked: false, timeSpent: 0, timeLimit: 60, validTime: false })

        const siteBlockerCommand = canvas.getByTestId('site-blocker-command-0')
        await userEvent.type(siteBlockerCommand, 'b')

        await waitFor(() => {
            expect(siteBlockerCommand.textContent).toMatch(/60 Minutes Left/)
            expect(siteBlockerCommand.textContent).toMatch(/Only available between 6pm and 1am/)
        })
    },
};

export const ViewTimeLeft: Story = {
    play: async (playContext) => {
        const canvas = within(playContext.canvasElement)

        await Loading.play?.(playContext)

        playContext.parameters.commandMessaging.sendMessage({ type: 'siteBlocker', blocked: false, timeSpent: 1, timeLimit: 60, validTime: true })

        const siteBlockerCommand = canvas.getByTestId('site-blocker-command-0')

        await waitFor(() => {
            expect(siteBlockerCommand.textContent).toMatch(/59 Minutes Left/)
        })
    },
};

export const StartAvailable: Story = {
    play: async (playContext) => {
        const canvas = within(playContext.canvasElement)

        await ViewTimeLeft.play?.(playContext)
        playContext.parameters.commandMessaging.sendMessage({
            type: 'siteBlocker',
            blocked: true,
            timeSpent: 0,
            timeLimit: 60,
            validTime: true
        })

        const siteBlockerCommand = canvas.getByTestId('site-blocker-command-0')
        await userEvent.type(siteBlockerCommand, 'b')
        expect(
            playContext.parameters.commandMessaging.lastReceivedMessages[playContext.parameters.commandMessaging.lastReceivedMessages.length - 1]
        ).toEqual({ type: 'siteBlocker' })

        playContext.parameters.commandMessaging.sendMessage({
            type: 'siteBlocker',
            blocked: false,
            timeSpent: 2,
            timeLimit: 60,
            validTime: true
        })

        await waitFor(() => {
            expect(siteBlockerCommand.textContent).toMatch(/58 Minutes Left/)
        })
    },
};

export const StopAvailable: Story = {
    play: async (playContext) => {
        const canvas = within(playContext.canvasElement)

        await StartAvailable.play?.(playContext)

        const siteBlockerCommand = canvas.getByTestId('site-blocker-command-0')
        playContext.parameters.commandMessaging.sendMessage({ type: 'siteBlocker', blocked: false, timeSpent: 1, timeLimit: 60, validTime: true })
        await userEvent.type(siteBlockerCommand, 'b')

        console.log(playContext.parameters.commandMessaging.lastReceivedMessages)
        expect(
            playContext.parameters.commandMessaging.lastReceivedMessages[playContext.parameters.commandMessaging.lastReceivedMessages.length - 1]
        ).toEqual({ type: 'siteBlocker' })

        playContext.parameters.commandMessaging.sendMessage({ type: 'siteBlocker', blocked: true, timeSpent: 2, timeLimit: 60, validTime: true })
        await waitFor(() => {
            expect(siteBlockerCommand.textContent).toMatch(/58 Minutes Left/)
        })
    },
};

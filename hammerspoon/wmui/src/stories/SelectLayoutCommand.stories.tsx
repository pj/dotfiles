import type { Meta, StoryObj } from '@storybook/react';

import { SelectLayoutCommand } from '../window_management/SelectLayoutCommand';
import { expect, userEvent, waitFor, within } from '@storybook/test';
import { CommandDecorator } from './CommandDecorator';
import { hammerspoonReady } from './utils';

const meta = {
    title: 'SelectLayoutCommand',
    component: SelectLayoutCommand,
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
} satisfies Meta<typeof SelectLayoutCommand>;

export default meta;
type Story = StoryObj<typeof meta>;
const defaultLayouts = {
    "type": 'windowManagement',
    "layouts": [
        {
            "name": "VLC",
            "quickKey": "v",
            "columns": [
                {
                    "type": "stack",
                    "span": 3
                },
                {
                    "type": "pinned",
                    "span": 1,
                    "application": "VLC"
                }
            ]
        },
        {
            "name": "Plex",
            "quickKey": "p",
            "columns": [
                {
                    "type": "stack",
                    "span": 3
                },
                {
                    "type": "pinned",
                    "span": 1,
                    "application": "Plex"
                }
            ]
        },
        {
            "name": "Split",
            "quickKey": "s",
            "columns": [
                {
                    "type": "stack",
                    "span": 1
                },
                {
                    "type": "empty",
                    "span": 1
                }
            ]
        }
    ]
};

export const Setup: Story = {
    play: async ({ canvasElement, parameters }) => {
        const canvas = await hammerspoonReady(canvasElement, parameters)

        const layoutCommand = canvas.getByTestId('layout-command-0')
        expect(layoutCommand).toBeInTheDocument()

        await waitFor(() => {
            expect(layoutCommand).toHaveFocus()
        })

        parameters.commandMessaging.sendMessage(defaultLayouts)
    },
};

import type { Meta, StoryObj } from '@storybook/react';

import { EditLayoutCommand } from '../window_management/EditLayoutCommand';
import { expect, waitFor } from '@storybook/test';
import { CommandDecorator } from './CommandDecorator';
import { hammerspoonReady } from './utils';

const meta = {
    title: 'EditLayoutCommand',
    component: EditLayoutCommand,
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
} satisfies Meta<typeof EditLayoutCommand>;

export default meta;
type Story = StoryObj<typeof meta>;
const defaultLayouts = {
    "type": 'windowManagement',
    "currentLayoutName": "VLC",
    "currentScreens": [
        {
            "name": "Primary",
            "primary": true
        }
    ],
    "layouts": [
        {
            "name": "VLC",
            "quickKey": "v",
            "screens": [
                {
                    "primary": {
                        "type": "columns",
                        "columns": [
                            {
                                "type": "stack",
                                "percentage": 75
                            },
                            {
                                "type": "pinned",
                                "percentage": 25,
                                "application": "VLC"
                            }
                        ]
                    }
                }
            ]
        },
        {
            "name": "Plex",
            "quickKey": "p",
            "screens": [
                {
                    "primary": {
                        "type": "columns",
                        "columns": [
                        {
                            "type": "stack",
                            "percentage": 75
                        },
                        {
                            "type": "pinned",
                            "percentage": 25,
                            "application": "Plex"
                        }
                        ]
                    }
                }
            ]
        },
        {
            "name": "Split",
            "quickKey": "s",
            "screens": [
                {
                    "primary": {
                        "type": "columns",
                        "columns": [
                            {
                                "type": "stack",
                                "percentage": 50
                            },
                            {
                                "type": "empty",
                                "percentage": 50
                            }
                        ]
                    }
                }
            ]
        },
        {
            "name": "VSplit",
            "quickKey": "w",
            "screens": [
                {
                    "primary": {
                        "type": "columns",
                        "columns": [
                            {
                                "type": "stack",
                                "percentage": 50
                            },
                            {
                                "type": "rows",
                                "percentage": 50,
                                "rows": [
                                    {
                                        "type": "empty",
                                        "percentage": 50
                                    },
                                    {
                                        "type": "pinned",
                                        "percentage": 50,
                                        "application": "Plex"
                                    }
                            ]
                        }
                        ]
                    }
                }
            ]
        }
    ]
};

export const Setup: Story = {
    play: async ({ canvasElement, parameters }) => {
        const canvas = await hammerspoonReady(canvasElement, parameters)

        const layoutCommand = canvas.getByTestId('edit-layout-command-0')
        expect(layoutCommand).toBeInTheDocument()

        await waitFor(() => {
            expect(layoutCommand).toHaveFocus()
        })

        parameters.commandMessaging.sendMessage(defaultLayouts)
    },
};

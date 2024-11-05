import { expect, within, waitFor } from "@storybook/test";

export async function hammerspoonReady(canvasElement: HTMLElement, parameters: any) {
  const canvas = within(canvasElement)
  await waitFor(() => {
    expect(parameters.commandMessaging.onMessage).not.toBeNull()
  })

  parameters.commandMessaging.sendMessage({ type: 'hammerspoonReady' })

  expect(parameters.commandMessaging.lastReceivedMessages[0]).toEqual({ type: 'uiReady' })
  expect(parameters.commandMessaging.lastReceivedMessages[1]).toEqual({ type: 'log', log: 'received message: {"type":"hammerspoonReady"}' })

  await waitFor(() => {
    expect(canvas.queryByTestId('app-loading')).not.toBeInTheDocument()
  })

  return canvas
}

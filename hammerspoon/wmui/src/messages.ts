import { z } from 'zod'

export const UIReadySchema = z.object({
  type: z.literal('uiReady'),
})

export type UIReady = z.infer<typeof UIReadySchema>

export const VolumeMuteSchema = z.object({
  type: z.literal('volumeMute'),
})

export type VolumeMute = z.infer<typeof VolumeMuteSchema>

export const VolumeUpSchema = z.object({
  type: z.literal('volumeUp'),
})

export type VolumeUp = z.infer<typeof VolumeUpSchema>

export const VolumeDownSchema = z.object({
  type: z.literal('volumeDown'),
})

export type VolumeDown = z.infer<typeof VolumeDownSchema>

export const UiDoneSchema = z.object({
  type: z.literal('uiDone'),
})

export type UiDone = z.infer<typeof UiDoneSchema>

export const LogSchema = z.object({
  type: z.literal('log'),
  log: z.string(),
})

export type Log = z.infer<typeof LogSchema>

export const ToMessageSchema = z.union([
  UIReadySchema,
  VolumeMuteSchema,
  VolumeUpSchema,
  VolumeDownSchema,
  UiDoneSchema,
  LogSchema,
])
export type ToMessage = z.infer<typeof ToMessageSchema>

// Hammerspoon -> UI
export const HammerspoonReadySchema = z.object({
  type: z.literal('hammerspoonReady'),
})

export type HammerspoonReady = z.infer<typeof HammerspoonReadySchema>

export const ScreenChangeSchema = z.object({  
  type: z.literal('screenChange'),
  screen: z.string(),
})

export type ScreenChange = z.infer<typeof ScreenChangeSchema>

export const ResetCommandInterpreterSchema = z.object({
  type: z.literal('resetCommandInterpreter'),
})

export type ResetCommandInterpreter = z.infer<typeof ResetCommandInterpreterSchema>

export const FromMessageSchema = z.union([
  HammerspoonReadySchema,
  ScreenChangeSchema,
  ResetCommandInterpreterSchema,
])

export type FromMessage = z.infer<typeof FromMessageSchema>

export function sendMessage(message: ToMessage) {
  // @ts-ignore
  webkit.messageHandlers.wmui.postMessage(message)
}
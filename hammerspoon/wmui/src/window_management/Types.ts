
export type Screen = {
    id: string
    name: string
    isMain: boolean
    currentVirtualDesktop: VirtualDesktop | null
    layout: Layout | null
    x: number
    y: number
    width: number
    height: number
}

export type Column = {
  type: "vsplit" | "stack" | "window" | "empty"
  span: number
  application?: string
  title?: string
}

export type Layout = {
    name: string
    quickKey: string
    columns: Column[]
}

export type Window = {
    id: string
    title: string
    focused: boolean
}

export type VirtualDesktop = {
    id: string
    windows: Window[]
    focusedWindow: Window | null
}

export type WindowManagementState = {
    screens: Screen[]
}

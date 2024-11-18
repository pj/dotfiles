
// export type Screen = {
//     id: string
//     name: string
//     isMain: boolean
//     currentVirtualDesktop: VirtualDesktop | null
//     layout: Layout | null
//     x: number
//     y: number
//     width: number
//     height: number
// }

export type ScreenLayout = {
    type: "screen"
    name: string
    root: Layout
}

export type RootLayout = {
    type: "root"
    screens: ScreenLayout[]
    name: string
    quickKey: string
    span: number
}

export type ColumnsLayout = {
    type: "columns"
    columns: Layout[]
    span: number
}

export type RowsLayout = {
    type: "rows"
    rows: Layout[]
    span: number
}

export type StackLayout = {
    type: "stack"
    span: number
}

export type PinnedLayout = {
    type: "pinned"
    span: number
    application?: string
    title?: string
}

export type EmptyLayout = {
    type: "empty"
    span: number
}

export type Layout = ColumnsLayout | RowsLayout | StackLayout | PinnedLayout | EmptyLayout

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
    layouts: RootLayout[]
}

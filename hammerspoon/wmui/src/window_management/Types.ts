export type RootLayout = {
    screens: {[screenName: string]: Layout}[]
    name: string
    quickKey: string
}

export type ColumnsLayout = {
    type: "columns"
    columns: Layout[]
    percentage: number
}

export type RowsLayout = {
    type: "rows"
    rows: Layout[]
    percentage: number
}

export type StackLayout = {
    type: "stack"
    percentage: number
}

export type PinnedLayout = {
    type: "pinned"
    percentage: number
    application?: string
    title?: string
}

export type EmptyLayout = {
    type: "empty"
    percentage: number
}

export type Layout = ColumnsLayout | RowsLayout | StackLayout | PinnedLayout | EmptyLayout

export type LayoutConstant = Layout extends any ? Layout["type"] : never;

// export type Window = {
//     id: string
//     title: string
//     focused: boolean
// }

// export type VirtualDesktop = {
//     id: string
//     windows: Window[]
//     focusedWindow: Window | null
// }

export type WindowManagementState = {
    layouts: RootLayout[]
    currentLayout: RootLayout
    currentLayoutName: string
    currentScreens: { name: string, primary: boolean }[]
}

export type Geometry = {
    w: number
    h: number
    x: number
    y: number
}

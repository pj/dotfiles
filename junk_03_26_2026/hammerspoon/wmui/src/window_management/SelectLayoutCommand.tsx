import { useContext } from "react"
import { AppExitContext, AppSendMessageContext, AppStateContext } from "../App"
import { DefaultCommandProps, defaultCommandProps, useFocus } from "../CommandWrapper"
import { Key } from "../Key"
import { Geometry, Layout as LayoutType, RootLayout as RootLayoutType, WindowManagementState } from "./Types"
import { CommandLoading } from "../CommandLoading"

export type LayoutCommandProps = DefaultCommandProps

const columnCss = "rounded-md text-xs bg-white flex flex-col border border-gray-300"
const columnStyle = { fontSize: "0.5rem" }
const layoutWidth = 160;
const layoutHeight = 100;

type LayoutProps = {
    layout: LayoutType
    frame: Geometry
}

function Window({ frame, text }: { frame: Geometry, text: string }) {
    return (
        <div style={{ ...columnStyle, width: frame.w, height: frame.h }} className={columnCss}>
            <div style={{ height: "4px" }} className="bg-gray-200 rounded-t-md flex flex-row items-center justify-start pl-1">
                <div style={{ height: "2px", width: "2px" }} className="bg-red-500 rounded-full"></div>
                <div style={{ height: "2px", width: "2px" }} className="bg-yellow-500 rounded-full"></div>
                <div style={{ height: "2px", width: "2px" }} className="bg-green-500 rounded-full"></div>
            </div>
            <hr className="border-gray-300" />
            <div className="flex h-full items-center justify-center text-center">{text}</div>
        </div>
    );
}


function Layout({ layout, frame }: LayoutProps) {
    if (layout.type === "columns") {
        let columns = [];
        for (const column of layout.columns) {
            let columnWidth = (column.percentage / 100) * frame.w;
            columns.push(<Layout layout={column} frame={{ w: columnWidth, h: frame.h, x: frame.x, y: frame.y }} />)
        }

        return (
            <div className="flex flex-row">
                {columns}
            </div>
        );
    } else if (layout.type === "rows") {
        let rows = [];
        for (const row of layout.rows) {
            let rowHeight = (row.percentage / 100) * frame.h;
            rows.push(<Layout layout={row} frame={{ w: frame.w, h: rowHeight, x: frame.x, y: frame.y }} />)
        }

        return (
            <div className="flex flex-col">
                {rows}
            </div>
        );
    }
    else if (layout.type === "stack") {
        return <Window frame={{ w: frame.w, h: frame.h, x: frame.x, y: frame.y }} text="Stack" />
    }
    else if (layout.type === "pinned") {
        return <Window frame={{ w: frame.w, h: frame.h, x: frame.x, y: frame.y }} text={layout.application || ""} />
    }
    else if (layout.type === "empty") {
        return <Window frame={{ w: frame.w, h: frame.h, x: frame.x, y: frame.y }} text="Empty" />
    }

    return (<div>Unknown layout type {JSON.stringify(layout)}</div>);
}

type RootLayoutProps = {
    layout: RootLayoutType
    frame: Geometry
    currentScreens: { name: string, primary: boolean }[]
}

function RootLayout({ layout, frame, currentScreens }: RootLayoutProps) {
    for (const screenSet of layout.screens) {
        let foundAllScreens = true;
        for (const currentScreen of currentScreens) {
            if (currentScreen.primary && screenSet["primary"]) {
                continue
            }
            if (screenSet[currentScreen.name]) {
                continue
            }
            foundAllScreens = false;
            break;
        }
        if (foundAllScreens) {
            let screenLayout = screenSet[currentScreens[0].name]
            if (!screenLayout && currentScreens[0].primary) {
                screenLayout = screenSet["primary"];
            }
            if (!screenLayout) {
                return <div key={layout.name}>Unable to find matching screens for layout {layout.name}</div>
            }
            return (
                <div key={layout.name}>
                    <div style={{ width: layoutWidth }} className="flex flex-row items-center justify-center p-1 gap-1">
                        <Key text={layout.quickKey}></Key>
                        <div className="text-xs">{layout.name}</div>
                    </div>
                    <div className="p-1 rounded-sm bg-black relative">
                        <Layout layout={screenLayout} frame={frame} />
                    </div>
                </div>
            )
        }
    }

    return (
        <div key={layout.name}>
            <div
                style={{ width: layoutWidth }}
                className="flex flex-row items-center justify-center p-1 gap-1">
                Unable to find matching screens for layout {layout.name}
            </div>
        </div>
    );
}

export function SelectLayoutCommand({ index, handleDelete }: LayoutCommandProps) {
    const { wrapperElement, setFocus } = useFocus()
    const appState = useContext(AppStateContext)

    const sendMessage = useContext(AppSendMessageContext)
    const handleExit = useContext(AppExitContext)

    const handleKeyDown = (event: React.KeyboardEvent<HTMLDivElement>) => {
        event.preventDefault()
        if (event.key === 'Escape') {
            handleExit();
            return;
        }
        if (event.key === 'Backspace') {
            handleDelete()
            return;
        }

        for (const layout of appState.windowManagement?.layouts || []) {
            if (layout.quickKey === event.key) {
                sendMessage({ type: "windowManagementSelectLayout", quickKey: layout.quickKey });
                handleExit();
                return;
            }
        }
    }

    const windowManagementState = appState.windowManagement as WindowManagementState | undefined

    return (
        <div
            key={index}
            {...defaultCommandProps(index, "layout-command", wrapperElement, setFocus)}
            onKeyDown={handleKeyDown}
        >
            <div className="text-xs text-center text-gray-600">Select Layout</div>
            <hr className="border-gray-300" />
            <div className="card-body">
                {
                    windowManagementState ? (
                        <>
                            <div className="flex flex-row divide-x *:px-2 first:*:pt-0 last:*:pb-0">
                                {
                                    windowManagementState.layouts.map((layout: RootLayoutType) => (
                                        <RootLayout
                                            layout={layout}
                                            frame={{ w: layoutWidth, h: layoutHeight, x: 0, y: 0 }}
                                            currentScreens={windowManagementState.currentScreens}
                                        />
                                    ))
                                }
                            </div>
                        </>
                    ) : <CommandLoading testId="layout-loading" />
                }
            </div>
        </div>
    );
}

import { useContext, useEffect, useReducer } from "react"
import { AppExitContext, AppStateContext } from "../App"
import { DefaultCommandProps, defaultCommandProps, useFocus } from "../CommandWrapper"
import { Geometry, LayoutConstant, Layout as LayoutType, RootLayout as RootLayoutType, WindowManagementState } from "./Types"
import { CommandLoading } from "../CommandLoading"

export type EditLayoutCommandProps = DefaultCommandProps

const columnCss = "h-24 rounded-md text-xs bg-white flex flex-col border border-gray-300"
const columnStyle = { fontSize: "0.5rem" }
const LAYOUT_WIDTH = 480;
const LAYOUT_HEIGHT = 270;

const ADD_ELEMENT_SIZE = 20;

type WindowProps = {
    frame: Geometry,
    children: React.ReactNode
}

function Window({ frame, children }: WindowProps) {
    return (
        <div style={{ ...columnStyle, width: frame.w, height: frame.h }} className={columnCss}>
            <div style={{ height: "4px" }} className="bg-gray-200 rounded-t-md flex flex-row items-center justify-start pl-1">
                <div style={{ height: "2px", width: "2px" }} className="bg-red-500 rounded-full"></div>
                <div style={{ height: "2px", width: "2px" }} className="bg-yellow-500 rounded-full"></div>
                <div style={{ height: "2px", width: "2px" }} className="bg-green-500 rounded-full"></div>
            </div>
            <hr className="border-gray-300" />
            <div className="flex h-full items-center justify-center text-center">{children}</div>
        </div>
    );
}

type LayoutProps = {
    layout: LayoutType,
    frame: Geometry,
    path: number[],
    setLayout: (action: LayoutChangeAction) => void
}

function Layout({ layout, frame, path, setLayout }: LayoutProps) {
    if (layout.type === "columns") {
        let columns = [];
        let availableSize = frame.w - ADD_ELEMENT_SIZE;
        for (let i = 0; i < layout.columns.length; i++) {
            const column = layout.columns[i];
            let columnWidth = (column.percentage / 100) * availableSize;
            columns.push(
                <Layout
                    layout={column}
                    frame={{ w: columnWidth, h: frame.h, x: frame.x, y: frame.y }}
                    path={[...path, i]}
                    setLayout={setLayout}
                />
            );
        }

        return (
            <div className="flex flex-row">
                {columns}
                <button
                    className="btn btn-sm btn-primary"
                    style={{ width: ADD_ELEMENT_SIZE, padding: "1" }}
                    onClick={() => setLayout({ type: "updateElement", path: path, percentage: 100, layoutType: "columns" })}
                >
                    +
                </button>
            </div>
        );
    } else if (layout.type === "rows") {
        let rows = [];
        let availableSize = frame.h - ADD_ELEMENT_SIZE;
        for (let i = 0; i < layout.rows.length; i++) {
            const row = layout.rows[i];
            let rowHeight = (row.percentage / 100) * availableSize;
            rows.push(
                <Layout
                    layout={row}
                    frame={{ w: frame.w, h: rowHeight, x: frame.x, y: frame.y }}
                    path={[...path, i]}
                    setLayout={setLayout}
                />
            );
        }

        return (
            <div className="flex flex-col">
                {rows}
                <button
                    className="btn btn-sm btn-primary p-1"
                    style={{ height: ADD_ELEMENT_SIZE, padding: "1" }}
                    onClick={() => setLayout({ type: "updateElement", path: path, percentage: 100, layoutType: "rows" })}
                >
                    +
                </button>
            </div>
        );
    }
    else if (layout.type === "stack") {
        return (
            <Window frame={{ w: frame.w, h: frame.h, x: frame.x, y: frame.y }} >
                Stack
            </Window>
        );
    }
    else if (layout.type === "pinned") {
        return (
            <Window frame={{ w: frame.w, h: frame.h, x: frame.x, y: frame.y }} >
                {layout.application || ""}
            </Window>
        );
    }
    else if (layout.type === "empty") {
        return (
            <Window frame={{ w: frame.w, h: frame.h, x: frame.x, y: frame.y }} >
                Empty
            </Window>
        );
    }

    return (<div>Unknown layout type {JSON.stringify(layout)}</div>);

}

type RootLayoutProps = {
    rootLayout: RootLayoutType | null,
    setLayout: (action: LayoutChangeAction) => void,
    currentScreens: WindowManagementState["currentScreens"]
}

function RootLayout({ rootLayout, setLayout, currentScreens }: RootLayoutProps) {
    if (rootLayout === null) {
        return <div>Please select a layout</div>;
    }

    const screen = currentScreens[0];

    let layout = rootLayout.screens[0][screen.name];

    if (layout === undefined && screen.primary && rootLayout.screens[0]["primary"]) {
        layout = rootLayout.screens[0]["primary"];
    }

    if (layout === undefined) {
        return <div>No layout found for screen {screen.name}</div>;
    }

    return (
        <Layout
            layout={layout}
            frame={{ w: LAYOUT_WIDTH, h: LAYOUT_HEIGHT, x: 0, y: 0 }}
            path={[]}
            setLayout={setLayout}
        />
    );
}

type LayoutBarProps = {
    layouts: RootLayoutType[],
    selectedLayout: RootLayoutType | null,
    setLayout: (action: LayoutChangeAction) => void
}

function LayoutBar({ layouts, selectedLayout, setLayout }: LayoutBarProps) {
    const handleCreateLayout = () => {
        setLayout({
            type: "setLayout",
            rootLayout: {
                quickKey: "",
                name: "",
                screens: [{
                    "primary": {
                        type: "columns",
                        percentage: 100,
                        columns: [{ type: "stack", percentage: 100 }]
                    }
                }]
            }
        })
    };

    const handleSelectLayout = (event: React.ChangeEvent<HTMLSelectElement>) => {
        const layout = layouts.find((layout: RootLayoutType) => layout.name === event.target.value);
        if (layout) {
            setLayout({ type: "setLayout", rootLayout: layout })
        }
    };

    const handleSaveLayout = () => {
    };

    const layoutOptions = layouts.map((layout: RootLayoutType) => {
        return <option key={layout.name} value={layout.name}>{layout.name}</option>
    });

    return (
            <div className="flex flex-col gap-1">
                <div className="flex flex-row gap-1">
                    <button className="btn btn-primary" onClick={handleCreateLayout}>+</button>
                    <select className="select select-bordered w-full max-w-xs" onChange={handleSelectLayout}>
                        {layoutOptions}
                    </select>
                </div>

                <div className="flex flex-row gap-1">
                    <label className="input input-bordered border-gray-300 flex items-center gap-2">
                        Quick Key
                        <input
                            type="text"
                            name="quickKey"
                            value={selectedLayout ? selectedLayout.quickKey : ""}
                            disabled={selectedLayout === null}
                            placeholder="Quick Key"
                            maxLength={1}
                            onChange={(event) => setLayout({ type: "changeQuickKey", quickKey: event.target.value })}
                        />
                    </label>

                    <label className="input input-bordered border-gray-300 flex items-center gap-2">
                        Name
                        <input
                            type="text"
                            name="name"
                            value={selectedLayout ? selectedLayout.name : ""}
                            disabled={selectedLayout === null}
                            placeholder="Layout Name"
                            onChange={(event) => setLayout({ type: "changeName", name: event.target.value })}
                        />
                    </label>
                    <button disabled={selectedLayout === null} className="btn btn-primary" onClick={handleSaveLayout}>Save</button>
                </div>
            </div>
    );

}

type LayoutChangeAction = {
    type: "changeQuickKey",
    quickKey: string
} | {
    type: "changeName",
    name: string
} | {
    type: "setLayout",
    rootLayout: RootLayoutType
} | {
    type: "updateElement",
    path: number[],
    percentage: number,
    application?: string,
    title?: string,
    layoutType: LayoutConstant
}

function handleLayoutChange(state: RootLayoutType | null, action: LayoutChangeAction): RootLayoutType | null {
    if (state === null) {
        if (action.type === "setLayout") {
            return action.rootLayout
        } else {
            return null;
        }
    }

    if (action.type === "setLayout") {
        return action.rootLayout
    } else if (action.type === "changeQuickKey") {
        return { ...state, quickKey: action.quickKey };
    } else if (action.type === "changeName") {
        return { ...state, name: action.name };
    }

    throw new Error("Invalid action type: " + action);
}

export function EditLayoutCommand({ index, handleDelete }: EditLayoutCommandProps) {
    const { wrapperElement, setFocus } = useFocus()
    const appState = useContext(AppStateContext)

    // const sendMessage = useContext(AppSendMessageContext)
    const handleExit = useContext(AppExitContext)

    const [rootLayout, setRootLayout] = useReducer<React.Reducer<RootLayoutType | null, LayoutChangeAction>>(handleLayoutChange, null)
    // const [errorMessage, setErrorMessage] = useState<string | null>(null)

    const handleKeyDown = (event: React.KeyboardEvent<HTMLDivElement>) => {
        if (event.target instanceof HTMLInputElement || event.target instanceof HTMLSelectElement) {
            return; // Let the input handle the event naturally
        }

        event.preventDefault()
        if (event.key === 'Escape') {
            handleExit();
            return;
        }
        if (event.key === 'Backspace') {
            handleDelete()
            return;
        }
    }

    useEffect(() => {
        if (rootLayout === null && appState.windowManagement) {
            setRootLayout({
                type: "setLayout",
                rootLayout: appState.windowManagement.layouts[0]
            })
        }
    }, [appState.windowManagement]);

    const windowManagementState = appState.windowManagement as WindowManagementState | undefined;

    return (
        <div
            key={index}
            {...defaultCommandProps(index, "edit-layout-command", wrapperElement, setFocus)}
            onKeyDown={handleKeyDown}
        >
            <div className="text-xs text-center text-gray-600">Edit Layout</div>
            <hr className="border-gray-300" />
            <div className="card-body">
                {
                    windowManagementState ? (
                        <>
                            <LayoutBar
                                layouts={windowManagementState.layouts}
                                selectedLayout={rootLayout}
                                setLayout={setRootLayout}
                            />
                            <RootLayout
                                rootLayout={rootLayout}
                                setLayout={setRootLayout}
                                currentScreens={windowManagementState.currentScreens}
                            />
                            {/* {
                                errorMessage &&
                                <div className="text-xs text-center text-red-500">
                                    {errorMessage}
                                </div>
                            } */}
                        </>
                    ) : <CommandLoading testId="edit-layout-loading" />
                }
            </div>
        </div>
    );
}

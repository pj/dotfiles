import { useContext, useEffect, useState } from "react"
import { AppExitContext, AppSendMessageContext, AppStateContext } from "../App"
import { DefaultCommandProps, defaultCommandProps, useFocus } from "../CommandWrapper"
import { Key } from "../Key"
import { Layout } from "./Types"
import { CommandLoading } from "../CommandLoading"

export type LayoutCommandProps = DefaultCommandProps

const columnCss = "w-12 h-16 rounded-md text-xs bg-white flex flex-col"
const columnStyle = { fontSize: "0.5rem" }
const layoutWidth = 120;

export function Column({ columnWidth, text }: { columnWidth: number, text: string }) {
    return (
        <div style={{ ...columnStyle, width: columnWidth }} className={columnCss}>
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

export function SelectLayoutCommand({ index, handleDelete }: LayoutCommandProps) {
    const { wrapperElement, setFocus } = useFocus()
    const appState = useContext(AppStateContext)

    const sendMessage = useContext(AppSendMessageContext)
    const handleExit = useContext(AppExitContext)

    const [errorMessage, setErrorMessage] = useState<string | null>(null)

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

    const layouts = appState.windowManagement?.layouts || [] as Layout[]

    let formattedLayouts = [];
    for (let i = 0; i < layouts.length; i++) {
        const layout = layouts[i];
        let totalSpan = 0;
        for (const column of layout.columns) {
            totalSpan += column.span;
        }
        let columns = [];
        for (const column of layout.columns) {
            let columnWidth = (column.span / totalSpan) * layoutWidth;
            if (column.type === "stack") {
                columns.push(
                    <>
                        <Column columnWidth={columnWidth} text="Stack" />
                    </>
                )
            } else if (column.type === "pinned") {
                columns.push(<Column columnWidth={columnWidth} text={column.application} />);
            } else if (column.type === "empty") {
                columns.push(<Column columnWidth={columnWidth} text="Empty" />);
            }
        }
        let layoutCss = "border-r border-gray-300 p-2"
        if (i === layouts.length - 1) {
            layoutCss = "p-2";
        }
        formattedLayouts.push(
            <div key={layout.name} className={layoutCss}>
                <div style={{ width: layoutWidth }} className="flex flex-row items-center justify-center p-1 gap-1">
                    <Key text={layout.quickKey}></Key>
                    <div className="text-xs">{layout.name}</div>
                </div>
                <div className="flex flex-row gap-1 p-1 rounded-sm bg-black relative">
                    {columns}
                </div>
            </div>
        );
    }

    console.log(appState.windowManagement)

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
                    appState.windowManagement ? (
                        <>
                            <div className="flex flex-row ">
                                {formattedLayouts}
                            </div>
                            {
                                errorMessage &&
                                <div className="text-xs text-center text-red-500">
                                    {errorMessage}
                                </div>
                            }
                        </>
                    ) : <CommandLoading testId="layout-loading" />
                }
            </div>
        </div>
    );
}

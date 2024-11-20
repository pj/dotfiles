// import { useContext, useEffect, useState } from "react"
// import { AppExitContext, AppSendMessageContext, AppStateContext } from "../App"
// import { DefaultCommandProps, defaultCommandProps, useFocus } from "../CommandWrapper"
// import { Layout } from "./Types"
// import { CommandLoading } from "../CommandLoading"

// export type EditLayoutCommandProps = DefaultCommandProps

// const columnCss = "h-24 rounded-md text-xs bg-white flex flex-col border border-gray-300"
// const columnStyle = { fontSize: "0.5rem" }
// const layoutWidth = 200;

// type ColumnProps = {
//     columnWidth: number,
//     columnIndex: number,
//     text: string,
//     setLayout: (layout: Layout) => void,
//     layout: Layout
// }

// function Column({ columnWidth, columnIndex, text, setLayout, layout }: ColumnProps) {
//     const handleIncreaseSpan = () => {
//         let columns = [...layout.columns];
//         columns[columnIndex].span += 1;
//         setLayout(
//             { ...layout, columns: columns }
//         );
//     }

//     const handleDecreaseSpan = () => {
//         if (layout.columns[columnIndex].span > 1) {
//             let columns = [...layout.columns];
//             columns[columnIndex].span -= 1;
//             setLayout(
//                 { ...layout, columns: columns }
//             );
//         }
//     }
//     const handleDeleteColumn = () => {
//         let columns = [...layout.columns];
//         columns.splice(columnIndex, 1);
//         setLayout({
//             ...layout,
//             columns: columns
//         })
//     }

//     return (
//         <div className="flex flex-col gap-1">
//             <div style={{ ...columnStyle, width: columnWidth }} className={columnCss}>
//                 <div style={{ height: "4px" }} className="bg-gray-200 rounded-t-md flex flex-row items-center justify-start pl-1">
//                     <div style={{ height: "2px", width: "2px" }} className="bg-red-500 rounded-full"></div>
//                     <div style={{ height: "2px", width: "2px" }} className="bg-yellow-500 rounded-full"></div>
//                     <div style={{ height: "2px", width: "2px" }} className="bg-green-500 rounded-full"></div>
//                 </div>
//                 <hr className="border-gray-300" />
//                 <div className="flex h-full items-center justify-center text-center">{text}</div>
//             </div>
//             <div className="flex flex-row gap-1">
//                 <button className="btn btn-sm btn-outline" onClick={handleIncreaseSpan}>+</button>
//                 <button className="btn btn-sm btn-outline" onClick={handleDeleteColumn}>x</button>
//                 <button className="btn btn-sm btn-outline" onClick={handleDecreaseSpan}>-</button>
//             </div>
//         </div>
//     );
// }

// export function EditLayoutCommand({ index, handleDelete }: EditLayoutCommandProps) {
//     const { wrapperElement, setFocus } = useFocus()
//     const appState = useContext(AppStateContext)

//     const sendMessage = useContext(AppSendMessageContext)
//     const handleExit = useContext(AppExitContext)

//     const [layout, setLayout] = useState<Layout | null>(null)

//     const [errorMessage, setErrorMessage] = useState<string | null>(null)

//     const handleKeyDown = (event: React.KeyboardEvent<HTMLDivElement>) => {
//         if (event.target instanceof HTMLInputElement || event.target instanceof HTMLSelectElement) {
//             return; // Let the input handle the event naturally
//         }

//         event.preventDefault()
//         if (event.key === 'Escape') {
//             handleExit();
//             return;
//         }
//         if (event.key === 'Backspace') {
//             handleDelete()
//             return;
//         }
//     }

//     useEffect(() => {
//         if (layout === null && appState.windowManagement) {
//             setLayout(appState.windowManagement.currentLayout)
//         }
//     }, [appState.windowManagement]);

//     const handleQuickKeyChange = (event: React.ChangeEvent<HTMLInputElement>) => {
//         if (layout) {
//             setLayout({ ...layout, quickKey: event.target.value })
//         }
//     }

//     const handleLayoutNameChange = (event: React.ChangeEvent<HTMLInputElement>) => {
//         if (layout) {
//             setLayout({ ...layout, name: event.target.value })
//         }
//     }

//     const handleLayoutChange = (event: React.ChangeEvent<HTMLSelectElement>) => {
//         if (appState.windowManagement) {
//             setLayout(appState.windowManagement.layouts.find((layout: Layout) => layout.name === event.target.value))
//         }
//     }

//     const handleAddColumn = () => {
//         if (layout) {
//             setLayout({ ...layout, columns: [...layout.columns, { type: "empty", span: 1 }] })
//         }
//     }

//     const handleSaveLayout = () => {
//         if (layout) {
//             sendMessage({ type: "windowManagementSaveLayout", layout: layout })
//         }
//     }

//     const handleNewLayout = () => {
//         setLayout({ quickKey: "", name: "", columns: [{ type: "stack", span: 1 }] })
//     }

//     let columns = [];
//     if (layout) {
//         let totalSpan = 0;
//         for (const column of layout.columns) {
//             totalSpan += column.span;
//         }
//         for (let x = 0; x < layout.columns.length; x++) {
//             let column = layout.columns[x];
//             let columnWidth = (column.span / totalSpan) * layoutWidth;
//             columns.push(
//                 <Column
//                     columnWidth={columnWidth}
//                     text={column.type}
//                     setLayout={setLayout}
//                     layout={layout}
//                     columnIndex={x}
//                 />
//             )
//         }
//     }

//     let layouts = [];
//     if (appState.windowManagement) {
//         for (const layout of appState.windowManagement.layouts) {
//             layouts.push(<option value={layout.name}>{layout.name}</option>)
//         }
//     }

//     return (
//         <div
//             key={index}
//             {...defaultCommandProps(index, "edit-layout-command", wrapperElement, setFocus)}
//             onKeyDown={handleKeyDown}
//         >
//             <div className="text-xs text-center text-gray-600">Edit Layout</div>
//             <hr className="border-gray-300" />
//             <div className="card-body">
//                 {
//                     appState.windowManagement ? (
//                         <>
//                             <div className="flex flex-col gap-2">
//                                 {
//                                     layout
//                                         ? <div className="flex flex-col gap-1">
//                                             <div className="flex flex-row gap-1">
//                                                 <label className="input input-bordered border-gray-300 flex items-center gap-2">
//                                                     Quick Key
//                                                     <input
//                                                         type="text"
//                                                         name="quickKey"
//                                                         value={layout.quickKey}
//                                                         disabled={layout === null}
//                                                         placeholder="Quick Key"
//                                                         maxLength={1}
//                                                         onChange={handleQuickKeyChange}
//                                                     />
//                                                 </label>

//                                                 <label className="input input-bordered border-gray-300 flex items-center gap-2">
//                                                     Name
//                                                     <input
//                                                         type="text"
//                                                         name="name"
//                                                         value={layout.name}
//                                                         disabled={layout === null}
//                                                         placeholder="Layout Name"
//                                                         onChange={handleLayoutNameChange}
//                                                     />
//                                                 </label>
//                                             </div>
//                                             <div className="flex flex-row gap-1">
//                                                 <div className="flex flex-row gap-1 p-1 items-center justify-start">
//                                                     {columns}
//                                                 </div>
//                                                 <button className="btn" onClick={handleAddColumn}>+</button>
//                                             </div>
//                                         </div>
//                                         : <div className="text-xs text-center text-gray-600">No layout selected</div>
//                                 }

//                                 <div className="flex flex-row gap-1">
//                                     <button className="btn btn-primary" onClick={handleNewLayout}>New Layout</button>
//                                     <select className="select select-bordered w-full max-w-xs" onChange={handleLayoutChange}>
//                                         {layouts}
//                                     </select>
//                                     <button disabled={layout === null} className="btn btn-primary" onClick={handleSaveLayout}>Save</button>
//                                 </div>
//                             </div>
//                             {
//                                 errorMessage &&
//                                 <div className="text-xs text-center text-red-500">
//                                     {errorMessage}
//                                 </div>
//                             }
//                         </>
//                     ) : <CommandLoading testId="edit-layout-loading" />
//                 }
//             </div>
//         </div>
//     );
// }

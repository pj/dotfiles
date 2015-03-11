// import { useContext, useEffect, useState } from "react"
// import { AppExitContext, AppSendMessageContext, AppStateContext } from "../App"
// import { DefaultCommandProps, defaultCommandProps, useFocus } from "../CommandWrapper"

// export type ScreenSelectCommandProps = DefaultCommandProps & {
//     useCurrentScreen?: boolean
// }

// export function ScreenSelectCommand({ index, handleDelete, useCurrentScreen }: ScreenSelectCommandProps) {
//     const { wrapperElement, setFocus } = useFocus()
//     const appState = useContext(AppStateContext)

//     const sendMessage = useContext(AppSendMessageContext)
//     const handleExit = useContext(AppExitContext)

//     const [selectedScreen, setSelectedScreen] = useState<string | null>(null)

//     const [errorMessage, setErrorMessage] = useState<string | null>(null)

//     const handleKeyDown = (event: React.KeyboardEvent<HTMLDivElement>) => {
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
//     }, [appState.windowManagement]);

//     // useEffect(() => {
//     //     if (useCurrentScreen) {
//     //         for (const screen of appState.windowManagement.screens) {
//     //         }
//     //     }
//     // }, [useCurrentScreen]);

//     return (
//         <div
//             key={index}
//             {...defaultCommandProps(index, "screen-select-command", wrapperElement, setFocus)}
//             onKeyDown={handleKeyDown}
//         >
//             <div className="text-xs text-center text-gray-600">Screen Select</div>
//             <hr className="border-gray-300"/>
//             <div className="card-body">
//                 {
//                 appState.windowManagement ? (
//                     <>
//                         {errorMessage && <div className="text-xs text-center text-red-500">{errorMessage}</div>}
//                     </>
//                     ) : <span data-testid="screen-select-loading" className="loading loading-bars loading-xl">Loading...</span>
//                 }
//             </div>
//         </div>
//         );
// }

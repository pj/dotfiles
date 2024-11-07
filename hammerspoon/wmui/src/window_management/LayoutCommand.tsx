import { useContext, useEffect, useState } from "react"
import { AppExitContext, AppSendMessageContext, AppStateContext } from "../App"
import { DefaultCommandProps, defaultCommandProps, useFocus } from "../CommandWrapper"
import { Key } from "../Key"

export type WindowManagementLayoutCommandProps = DefaultCommandProps & {
    layouts: Map<string, string>
}

export function WindowManagementLayoutCommand({ index, handleDelete }: WindowManagementLayoutCommandProps) {
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
    }

    useEffect(() => {
    }, [appState.windowManagement])

    return (
        <div
            key={index}
            {...defaultCommandProps(index, "window-management-layout-command", wrapperElement, setFocus)}
            onKeyDown={handleKeyDown}
        >
            <div className="text-xs text-center text-gray-600">Window Management Layout</div>
            <hr className="border-gray-300"/>
            <div className="card-body">
                {
                appState.windowManagement ? (
                    <>
                        {errorMessage && <div className="text-xs text-center text-red-500">{errorMessage}</div>}
                    </>
                    ) : <span data-testid="window-management-layout-loading" className="loading loading-bars loading-xl">Loading...</span>
                }
            </div>
        </div>
        );
}

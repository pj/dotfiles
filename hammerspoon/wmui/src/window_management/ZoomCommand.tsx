import { useContext, useEffect, useState } from "react"
import { AppExitContext, AppSendMessageContext, AppStateContext } from "../App"
import { DefaultCommandProps, defaultCommandProps, useFocus } from "../CommandWrapper"
import { CommandLoading } from "../CommandLoading"

export type ZoomCommandProps = DefaultCommandProps & {
    zoomCurrent: boolean
}

export function ZoomCommand({ index, handleDelete, zoomCurrent }: ZoomCommandProps) {
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
        if (zoomCurrent) {
            sendMessage({ type: "windowManagementZoomToggle" })
            handleExit();
        }
    }, []);

    return (
        <div
            key={index}
            {...defaultCommandProps(index, "zoom-command", wrapperElement, setFocus)}
            onKeyDown={handleKeyDown}
        >
            <div className="text-xs text-center text-gray-600">Zoom</div>
            <hr className="border-gray-300" />
            <div className="card-body">
                {
                    appState.windowManagement ? (
                        null
                    ) : <CommandLoading testId="layout-loading" />
                }
            </div>
        </div>
    );
}

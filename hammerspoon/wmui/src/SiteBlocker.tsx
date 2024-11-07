import { useContext, useState } from "react"
import { AppExitContext, AppSendMessageContext, AppStateContext } from "./App"
import { DefaultCommandProps, defaultCommandProps, useFocus } from "./CommandWrapper"
import { Key } from "./Key"

export type SiteBlockerCommandProps = DefaultCommandProps

export function SiteBlockerCommand({ index, handleDelete }: SiteBlockerCommandProps) {
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
        if (event.key === 'b') {
            if (appState.siteBlocker && !appState.siteBlocker.validTime) {
                setErrorMessage("Only available between 6pm and 1am")
                return;
            }
            sendMessage({ type: 'siteBlocker', isBlocked: !appState.siteBlocker.isBlocked })
            return;
        }
    }

    let secondsLeft = null
    if (appState.siteBlocker) {
        secondsLeft = appState.siteBlocker.totalSeconds - appState.siteBlocker.timeSpent;
    }

    sendMessage({ type: 'log', message: JSON.stringify(appState.siteBlocker) })

    return (
        <div
            key={index}
            {...defaultCommandProps(index, "site-blocker-command", wrapperElement, setFocus)}
            onKeyDown={handleKeyDown}
        >
            <div className="text-xs text-center text-gray-600">Site Blocker</div>
            <hr className="border-gray-300"/>
            <div className="card-body">
                {
                appState.siteBlocker ? (
                    <>
                        <label className="flex flex-row items-center gap-2 label cursor-pointer justify-start">
                            <Key key="B" text="B"/>
                            <input
                                type="checkbox"
                                className="checkbox"
                                disabled={!appState.siteBlocker.validTime}
                                checked={appState.siteBlocker.isBlocked}
                                onChange={() => sendMessage({ type: 'siteBlocker', isBlocked: !appState.siteBlocker.isBlocked })}
                            />
                            <div className={`label-text ${!appState.siteBlocker.validTime ? "text-gray-400" : "text-gray-600"}`}>
                                {secondsLeft !== null ? Math.trunc(secondsLeft / 60) : "--"} Minutes Left
                            </div>
                        </label>
                        {errorMessage && <div className="text-xs text-center text-red-500">{errorMessage}</div>}
                    </>
                    ) : <span data-testid="site-blocker-loading" className="loading loading-bars loading-xl">Loading...</span>
                }
            </div>
        </div>
        );
}

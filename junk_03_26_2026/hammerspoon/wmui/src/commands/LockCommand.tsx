import { useContext } from "react"
import { AppExitContext, AppSendMessageContext } from "../App"
import { DefaultCommandProps, defaultCommandProps, useFocus } from "../CommandWrapper"
import { Key } from "../Key"

export type LockCommandProps = DefaultCommandProps

export function LockCommand({ index, handleDelete }: LockCommandProps) {
    const { wrapperElement, setFocus } = useFocus()

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
        if (event.key === 'l') {
            sendMessage({ type: 'lockScreen' });
            handleExit();
            return;
        }
    }

    return (
        <div
            key={index}
            {...defaultCommandProps(index, "lock-command", wrapperElement, setFocus)}
            onKeyDown={handleKeyDown}
        >
            <div className="text-xs text-center text-gray-600">Lock Screen</div>
            <hr className="border-gray-300" />
            <div className="card-body">
                {
                    <>
                        <div className="form-control">
                            <label className="label cursor-pointer flex flex-row items-center gap-3 justify-start">
                                <Key key="L" text="L" />
                                <button
                                    className="btn btn-primary btn-xl"
                                    data-testid={"lock-button-" + index}
                                    onClick={() => sendMessage({ type: 'lockScreen' })}
                                >
                                    Lock Screen
                                </button>
                            </label>
                        </div>
                    </>
                }
            </div>
        </div>
    );
}

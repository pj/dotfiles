import { useContext } from "react"
import { AppExitContext, AppSendMessageContext, AppStateContext } from "../App"
import { DefaultCommandProps, defaultCommandProps, useFocus } from "../CommandWrapper"
import { Key } from "../Key"

type VolumeState = {
    muted: boolean
    volume: number
};

export type VolumeCommandProps = DefaultCommandProps

export function VolumeCommand({ index, handleDelete }: VolumeCommandProps) {
    const { wrapperElement, setFocus } = useFocus()
    const appState = useContext(AppStateContext)

    const sendMessage = useContext(AppSendMessageContext)
    const handleExit = useContext(AppExitContext)

    // const [errorMessage, setErrorMessage] = useState<string | null>(null)

    const volumeState = appState.volume as VolumeState | undefined;

    const handleKeyDown = (event: React.KeyboardEvent<HTMLDivElement>) => {
        event.preventDefault()
        console.log("key: ", event)
        if (event.key === 'Escape') {
            handleExit();
            return;
        }
        if (event.key === 'Backspace') {
            handleDelete()
            return;
        }
        if (event.key === 'm') {
            if (volumeState) {
                sendMessage({ type: 'volumeMute' })
            }
            return;
        }
        if (event.key === 'u') {
            if (volumeState) {
                sendMessage({ type: 'volumeUp' })
            }
            return;
        }
        if (event.key === 'd') {
            if (volumeState) {
                sendMessage({ type: 'volumeDown' })
            }
            return;
        }
    }

    return (
        <div
            key={index}
            {...defaultCommandProps(index, "volume-command", wrapperElement, setFocus)}
            onKeyDown={handleKeyDown}
        >
            <div className="text-xs text-center text-gray-600">Volume</div>
            <hr className="border-gray-300" />
            <div className="card-body">
                {
                    volumeState ? (
                        <>
                            <div className="form-control">
                                <label className="label cursor-pointer flex flex-row items-center gap-2 justify-start">
                                    <Key key="M" text="M" />
                                    <span className="label-text">Mute</span>
                                    <input
                                        type="checkbox"
                                        className="toggle toggle-primary toggle-lg"
                                        checked={volumeState.muted}
                                        onChange={() => sendMessage({ type: 'volumeMute' })}
                                    />
                                </label>
                            </div>

                            <div className="flex flex-row items-center gap-2 justify-start">
                                <Key key="D" text="D" />
                                <button
                                    className="btn btn-sm "
                                    data-testid={"volume-down-" + index}
                                    disabled={volumeState.muted}
                                    onClick={() => sendMessage({ type: 'volumeDown' })}
                                >
                                    -</button>
                                <input
                                    className={`range range-primary range-lg ${volumeState.muted ? "[--range-shdw:gray]" : ""}`}
                                    min="0"
                                    max="100"
                                    value={volumeState.volume}
                                    disabled={volumeState.muted}
                                    type="range"
                                    onChange={(event) => sendMessage({ type: 'volumeSet', volume: parseInt(event.target.value) })}
                                />
                                <button
                                    className="btn btn-sm"
                                    data-testid={"volume-up-" + index}
                                    disabled={volumeState.muted}
                                    onClick={() => sendMessage({ type: 'volumeUp' })}
                                >
                                    +</button>
                                <Key key="U" text="U" />
                            </div>
                            {/* {errorMessage && <div className="text-xs text-center text-red-500">{errorMessage}</div>} */}
                        </>
                    ) : <span data-testid="volume-loading" className="loading loading-bars loading-xl">Loading...</span>
                }
            </div>
        </div>
    );
}

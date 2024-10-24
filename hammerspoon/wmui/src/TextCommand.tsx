import { defaultCommandProps, DefaultCommandProps, useFocus } from "./CommandWrapper";

export type NullCommandProps = DefaultCommandProps & {
    text: string
}

export function TextCommand(props: NullCommandProps) {
    const { wrapperElement, setFocus } = useFocus()
    function keyHandler(event: React.KeyboardEvent<HTMLDivElement>) {
        if (event.key === 'Backspace' || event.key === 'Delete') {
            props.handleDelete()
        }
    }

    return (<>
        <div
            onKeyDown={keyHandler}
            {...defaultCommandProps(props.index, "text-command", wrapperElement, setFocus)}
        >
            <div>{props.text}</div>
        </div>
    </>)
}
import { defaultCommandProps, DefaultCommandProps, useFocus } from "../CommandWrapper";

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
        key={props.index}
        {...defaultCommandProps(props.index, "text-command", wrapperElement, setFocus)}
        onKeyDown={keyHandler}
    >
        <div className="text-xs text-center text-gray-600">Text</div>
            <hr className="border-gray-300"/>
            <div className="card-body">
                {props.text}
            </div>
    </div>
</>);
}

export type KeyProps = {
    text: string
}
export function Key(props: KeyProps) {
    return (
        // <div className="border border-gray-600 rounded-md p-1 text-xs text-center align-top bg-gray-700 text-white h-4 w-4 flex items-center justify-center">
        <kbd className="kbd kbd-sm">
            {props.text}
        </kbd>
    )
}
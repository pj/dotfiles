import { CommandWrapper, WrappedCommandGenerateProps } from "./CommandWrapper";
import { DefaultCommandProps } from "./CommandWrapper";

export type NullCommandProps = DefaultCommandProps & {
  text: string
}

type InnerNullCommandProps = WrappedCommandGenerateProps & {
  text: string
}

function nullCommandGenerate({ text, handleDelete }: InnerNullCommandProps) {
    return {
        inner: <div>{text}</div>,
        next: null,
        keyHandler: (event: React.KeyboardEvent<HTMLDivElement>) => {
            if (event.key === 'Backspace' || event.key === 'Delete') {
                handleDelete()
            }
        }
    }
}

export function TextCommand({ index, text, handleDelete }: NullCommandProps) {
  return (
    <CommandWrapper 
        index={index} 
        testId="null-command" 
        generate={nullCommandGenerate} 
        additionalProps={{ text }} 
        handleDelete={handleDelete}
    />
  );
}
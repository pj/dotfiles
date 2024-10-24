import { CommandWrapper } from "./CommandWrapper";

export type NullCommandProps = {
  index: number
  text: string
}

type InnerNullCommandProps = {
  text: string
}

function InnerNullCommand({ text }: InnerNullCommandProps) {
    return <div>{text}</div>
}

export function TextCommand({ index, text }: NullCommandProps) {
  return (
    <CommandWrapper 
        index={index} 
        testId="null-command" 
        component={InnerNullCommand} 
        additionalProps={{ text }} 
        nextCommand={null} 
    />
  );
}
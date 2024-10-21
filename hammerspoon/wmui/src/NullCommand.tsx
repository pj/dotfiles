import { CommandWrapper } from "./CommandWrapper";

export type NullCommandProps = {
  index: number
}

export function NullCommand({ index }: NullCommandProps) {
  return (
    <CommandWrapper index={index}>
        <div>
            Null
        </div>
    </CommandWrapper>
  );
}
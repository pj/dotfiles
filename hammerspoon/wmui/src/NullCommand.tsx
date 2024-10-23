import { CommandWrapper } from "./CommandWrapper";

export type NullCommandProps = {
  index: number
}

export function NullCommand() {
  return (
    <CommandWrapper index={1} testId="null-command">
        <div>
            Null
        </div>
    </CommandWrapper>
  );
}
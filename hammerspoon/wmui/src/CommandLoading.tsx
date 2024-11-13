type CommandLoadingProps = {
    testId: string
}

export function CommandLoading({ testId }: CommandLoadingProps) {
    return (<span data-testid={testId} className="loading loading-bars loading-xl">Loading...</span>);
}
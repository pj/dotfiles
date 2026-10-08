import { spawn } from "node:child_process"
import type { Plugin } from "@kilocode/plugin"

// Path is filled in by nix (home-manager/home.nix, pkgs.replaceVars) so the
// plugin always points at the agent-notify-hook built from the same dotfiles
// revision. See the notifyHook definition there for the click/tmux behaviour.
const HOOK = "@agentNotifyHook@"

const MESSAGES: Record<string, string> = {
  "session.idle": "Kilo finished responding",
  "session.error": "Kilo stopped with an error",
  "permission.asked": "Kilo needs your permission",
}

const Notify: Plugin = async () => ({
  event: async ({ event }) => {
    const message = MESSAGES[event.type]
    if (!message) return
    try {
      const child = spawn(HOOK, [], {
        stdio: ["pipe", "ignore", "ignore"],
        detached: true,
        env: {
          ...process.env,
          NOTIFY_TITLE: "Kilo Code",
          NOTIFY_LOG: process.env.HOME + "/.kilo/kilo-notify-hook.log",
          // Silent banner: the built-in attention sound in tui.json already
          // provides the audio cue, so the clickable one shouldn't beep too.
          NOTIFY_SOUND: "",
        },
      })
      child.on("error", () => {})
      child.stdin?.end(JSON.stringify({ message }))
      child.unref()
    } catch {
      // best-effort notification; never break the session
    }
  },
})

export default { id: "kilo-notify", server: Notify }

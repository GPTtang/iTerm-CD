#!/usr/bin/env python3
"""
iTerm CD To Current
-------------------
An iTerm2 status bar component that shows the current working directory
and lets you click "cd to ▶" to run `cd <path>` in the active session.

Requires:
  - iTerm2 with Python Runtime installed
  - Shell integration enabled so iTerm2 can track the current directory

Settings (via defaults write):

  # A. 最多显示几段路径（0 = 完整路径）
  defaults write io.github.iterm-cd max-path-segments -int 3

  # B. 点击后是否清屏
  defaults write io.github.iterm-cd clear-on-cd -bool true

  # C. 点击动作: cd（默认）| copy（复制路径）| finder（在 Finder 中打开）
  defaults write io.github.iterm-cd click-action -string copy
"""

import iterm2
import os
import shlex
import subprocess


APP_DOMAIN = "io.github.iterm-cd"


# ── Settings ─────────────────────────────────────────────────────────────────

def _defaults_read(key: str) -> str | None:
    """Read a single key from our defaults domain. Returns None if not set."""
    r = subprocess.run(
        ["defaults", "read", APP_DOMAIN, key],
        capture_output=True, text=True,
    )
    return r.stdout.strip() if r.returncode == 0 else None


class Settings:
    """Lazily reads user defaults; re-reads on each click so changes take effect
    without restarting the script."""

    @property
    def max_path_segments(self) -> int:
        v = _defaults_read("max-path-segments")
        try:
            return max(0, int(v)) if v is not None else 0
        except ValueError:
            return 0

    @property
    def clear_on_cd(self) -> bool:
        v = _defaults_read("clear-on-cd")
        return (v or "").lower() in ("1", "true", "yes")

    @property
    def click_action(self) -> str:
        v = _defaults_read("click-action")
        return v if v in ("cd", "copy", "finder") else "cd"


settings = Settings()


# ── Helpers ───────────────────────────────────────────────────────────────────

def shorten_path(path: str, max_segments: int) -> str:
    """
    Collapse the middle of a path so at most `max_segments` directory
    components are visible.

    Examples (max_segments=2):
      /Users/me/projects/myapp/src  →  ~/…/myapp/src
      ~/work                        →  ~/work          (already short)
    """
    home = os.path.expanduser("~")
    display = path.replace(home, "~", 1) if path.startswith(home) else path

    if max_segments <= 0:
        return display

    parts = display.split("/")
    # parts[0] is "" (absolute) or "~" (home-relative)
    if len(parts) <= max_segments + 1:
        return display

    head = parts[0]          # "" or "~"
    tail = parts[-max_segments:]
    return head + "/\u2026/" + "/".join(tail)


# ── Main ──────────────────────────────────────────────────────────────────────

async def main(connection):
    component = iterm2.StatusBarComponent(
        short_description="cd to...",
        detailed_description=(
            "Shows the current directory. "
            "Click ▶ to cd / copy path / open in Finder. "
            "Configure with: defaults write io.github.iterm-cd <key> <value>"
        ),
        knobs=[],
        exemplar="~/projects/myapp ▶",
        update_cadence=None,
        identifier="io.github.iterm-cd.cd-to-current",
    )

    # ── A: display with optional path shortening ──────────────────────────────
    @iterm2.StatusBarRPC
    async def cwd_component(knobs, path=iterm2.Reference("path")):
        if not path:
            return "cd to..."
        display = shorten_path(path, settings.max_path_segments)
        return f"{display} \u25b6"

    # ── C: click actions ──────────────────────────────────────────────────────
    async def on_click(session_id):
        app = await iterm2.async_get_app(connection)
        session = app.get_session_by_id(session_id)
        if session is None:
            return

        path = await session.async_get_variable("path")
        if not path:
            return

        action = settings.click_action

        if action == "copy":
            # Copy path to clipboard
            subprocess.run(["pbcopy"], input=path.encode())

        elif action == "finder":
            # Reveal in Finder
            subprocess.run(["open", path])

        else:
            # B: cd, with optional clear
            cmd = f"cd {shlex.quote(path)}"
            if settings.clear_on_cd:
                cmd += " && clear"
            await session.async_send_text(cmd + "\n")

    await component.async_register(connection, cwd_component, onclick=on_click)
    await iterm2.async_main(connection)


iterm2.run_forever(main)

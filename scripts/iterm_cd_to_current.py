#!/usr/bin/env python3

import html
import shlex
from typing import List, Optional

import iterm2


BADGE_PREFIX = "cd to"
BADGE_MAX_PATH = 44
LABEL_MAX_PATH = 54
TITLE_MAX_PATH = 72


def shorten_path(path: str, max_length: int) -> str:
    path = (path or "").strip()
    if not path:
        return "unknown"
    if path == "/":
        return "/"
    if len(path) <= max_length:
        return path

    segments = [segment for segment in path.split("/") if segment]
    if not segments:
        return "/"

    if len(segments) == 1:
        tail = segments[0]
        keep = max(1, max_length - 2)
        return f"/…{tail[-keep:]}"

    compact = []
    for index, segment in enumerate(segments):
        if index == len(segments) - 1:
            compact.append(segment)
        elif segment.startswith(".") and len(segment) > 1:
            compact.append(segment[:2])
        else:
            compact.append(segment[:1])

    candidate = "/" + "/".join(compact)
    if len(candidate) <= max_length:
        return candidate

    tail_keep = max(1, max_length - 1)
    return f"…{path[-tail_keep:]}"


def format_badge(path: str) -> str:
    return f"{BADGE_PREFIX}\n{shorten_path(path, BADGE_MAX_PATH)}"


def format_title(path: str) -> str:
    return f"{BADGE_PREFIX} {shorten_path(path, TITLE_MAX_PATH)}"


def format_status_variants(path: str) -> List[str]:
    full = (path or "").strip() or "unknown"
    basename = full.rstrip("/").split("/")[-1] if full not in {"", "/"} else "/"
    variants = [
        f"{BADGE_PREFIX} {full}",
        f"{BADGE_PREFIX} {shorten_path(full, LABEL_MAX_PATH)}",
        f"{BADGE_PREFIX} {basename}",
        BADGE_PREFIX,
    ]
    deduped = []
    for item in variants:
        if item not in deduped:
            deduped.append(item)
    return deduped


async def read_session_path(session: iterm2.Session) -> Optional[str]:
    for name in ("path", "session.path"):
        try:
            value = await session.async_get_variable(name)
        except Exception:
            continue
        if isinstance(value, str) and value.strip():
            return value.strip()
    return None


async def apply_badge(session: iterm2.Session, path: Optional[str]) -> None:
    update = iterm2.LocalWriteOnlyProfile()
    update.set_badge_text(format_badge(path or "unknown"))
    await session.async_set_profile_properties(update)


def popover_html(path: str, command: str) -> str:
    escaped_path = html.escape(path)
    escaped_command = html.escape(command)
    return f"""
    <html>
      <body style="font: 13px -apple-system, BlinkMacSystemFont, sans-serif; padding: 12px; color: #1f2937;">
        <div style="font-weight: 600; margin-bottom: 8px;">cd 已发送到当前 Session</div>
        <div style="margin-bottom: 6px;"><strong>目录</strong></div>
        <div style="margin-bottom: 10px; word-break: break-all;">{escaped_path}</div>
        <div style="margin-bottom: 6px;"><strong>命令</strong></div>
        <code style="display: block; white-space: pre-wrap;">{escaped_command}</code>
      </body>
    </html>
    """


async def main(connection: iterm2.Connection) -> None:
    app = await iterm2.async_get_app(connection)

    component = iterm2.StatusBarComponent(
        short_description="CD To Current Directory",
        detailed_description=(
            "Show the current directory and click to inject a cd command "
            "for that directory into the current session."
        ),
        knobs=[],
        exemplar="cd to /Users/name/workspace/project",
        update_cadence=None,
        identifier="com.liyong.iterm.cd-to-current-directory",
    )

    async def sync_badge(session_id: str) -> None:
        session = app.get_session_by_id(session_id)
        if not session:
            return

        initial_path = await read_session_path(session)
        await apply_badge(session, initial_path)

        async with iterm2.VariableMonitor(
            connection,
            iterm2.VariableScopes.SESSION,
            "path",
            session_id,
        ) as monitor:
            while True:
                path = await monitor.async_get()
                session = app.get_session_by_id(session_id)
                if not session:
                    return
                value = path if isinstance(path, str) and path.strip() else None
                await apply_badge(session, value)

    @iterm2.TitleProviderRPC
    async def cd_to_title(path=iterm2.Reference("path?")):
        return format_title(path or "unknown")

    @iterm2.StatusBarRPC
    async def cd_to_status_bar(knobs, path=iterm2.Reference("path?")):
        return format_status_variants(path or "unknown")

    async def send_cd(session_id: str) -> None:
        session = app.get_session_by_id(session_id)
        if not session:
            return

        path = await read_session_path(session)
        if not path:
            await component.async_open_popover(
                session_id,
                """
                <html>
                  <body style="font: 13px -apple-system, BlinkMacSystemFont, sans-serif; padding: 12px;">
                    当前 session 没有可用的路径信息。请先启用 iTerm2 Shell Integration。
                  </body>
                </html>
                """,
                iterm2.Size(340, 90),
            )
            return

        command = f"cd -- {shlex.quote(path)}\n"
        await session.async_send_text(command, suppress_broadcast=True)
        await component.async_open_popover(
            session_id,
            popover_html(path, command.rstrip()),
            iterm2.Size(420, 150),
        )

    @iterm2.RPC
    async def cd_to_current_directory(session_id=iterm2.Reference("id")):
        await send_cd(session_id)

    @iterm2.RPC
    async def cd_to_current_directory_click(session_id):
        await send_cd(session_id)

    await cd_to_title.async_register(
        connection,
        "CD To Current Directory",
        "com.liyong.iterm.cd-to-current-directory.title",
    )
    await cd_to_current_directory.async_register(connection)
    await component.async_register(
        connection,
        cd_to_status_bar,
        onclick=cd_to_current_directory_click,
    )

    await iterm2.EachSessionOnceMonitor.async_foreach_session_create_task(
        app,
        sync_badge,
    )


iterm2.run_forever(main)

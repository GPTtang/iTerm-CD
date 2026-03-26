#!/usr/bin/env bash
# uninstall.sh — 卸载 cd to iTerm2

set -euo pipefail

# 移除 Finder 工具栏 App
if [[ -d "/Applications/cd to iTerm2.app" ]]; then
  rm -rf "/Applications/cd to iTerm2.app"
  echo "✅  已移除 Finder 工具栏 App"
fi

# 移除 Quick Action
if [[ -d "$HOME/Library/Services/cd to iTerm2.workflow" ]]; then
  rm -rf "$HOME/Library/Services/cd to iTerm2.workflow"
  /System/Library/CoreServices/pbs -update
  echo "✅  已移除 Finder 快速操作"
fi

echo "✅  卸载完成"

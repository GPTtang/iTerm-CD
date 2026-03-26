# iTerm CD To Current

两个小工具，让 iTerm2 与 Finder 之间的目录跳转更顺手：

- **在 Finder 里** 找到目录，一键在 iTerm2 打开
- **在 iTerm2 里** 点状态栏路径，快速 cd 到目标目录

---

## 工具一：Finder 工具栏 App

[![Download](https://img.shields.io/github/v/release/GPTtang/iTerm-CD?label=Download&logo=github)](https://github.com/GPTtang/iTerm-CD/releases/latest/download/cd-to-iTerm2.zip)

**安装**

1. 下载 [cd-to-iTerm2.zip](https://github.com/GPTtang/iTerm-CD/releases/latest/download/cd-to-iTerm2.zip) 并解压
2. 将 `cd to iTerm2.app` 移入 `~/Applications`
3. 打开 Finder，按住 **⌘** 将 App 拖入工具栏

**首次点击时**，macOS 会请求 Finder 权限 → 点「去授权」→ 在系统设置中勾选 Finder → 完成。

**使用**

| 操作 | 效果 |
|------|------|
| 点击工具栏按钮 | 在 iTerm2 打开当前 Finder 目录 |
| 右键 → Quick Actions → cd to iTerm2 | 在 iTerm2 打开选中的文件夹 |

---

## 工具二：iTerm2 状态栏组件

在状态栏实时显示当前路径，点击即执行 `cd`。

```
~/projects/myapp/src ▶
```

**安装**

```bash
git clone https://github.com/GPTtang/iTerm-CD.git
cd iTerm-CD
bash install.sh
```

脚本运行完成后，在 iTerm2 中点击一次：**Scripts → Manage → Install Python Runtime**

重开 iTerm2 窗口，状态栏即显示当前路径。

**设置**（可选）

```bash
# 路径过长时只显示最后 N 段
defaults write io.github.iterm-cd max-path-segments -int 3

# cd 后自动清屏
defaults write io.github.iterm-cd clear-on-cd -bool true

# 点击动作：cd（默认）/ copy 复制路径 / finder 在 Finder 打开
defaults write io.github.iterm-cd click-action -string copy
```

**卸载**

```bash
bash uninstall.sh
```

---

## 致谢

本项目灵感来自 [cdto](https://github.com/jbtule/cdto)，感谢 [@jbtule](https://github.com/jbtule) 的出色工作。

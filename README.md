# iTerm CD To Current

本项目包含两个独立工具，都围绕"快速 cd 到目标目录"这一需求：

| 工具 | 入口 | 功能 |
|------|------|------|
| **状态栏组件** | iTerm2 状态栏 | 显示当前目录，点击在同一 session 执行 cd |
| **Finder 快速操作** | Finder 右键菜单 / 工具栏 | 在 Finder 中选中目录，一键在 iTerm2 打开 |

---

## 工具一：iTerm2 状态栏组件

在 iTerm2 状态栏显示当前目录路径，点击即执行 `cd`。

```
~/projects/myapp ▶
```

### 安装

**前提**：已安装 [iTerm2](https://iterm2.com/)

```bash
git clone https://github.com/your-username/iTerm-CD.git
cd iTerm-CD
bash install.sh
```

脚本自动完成：
- 安装 AutoLaunch 脚本到 iTerm2
- 安装 Shell Integration（追踪当前目录）
- 启用状态栏并添加 `cd to...` 组件

**最后一步**：iTerm2 菜单 → Scripts → Manage → Install Python Runtime → 点 Install

安装完成后重开一个 iTerm2 窗口，状态栏即出现路径显示。

### 使用

| 操作 | 效果 |
|------|------|
| 单击状态栏路径 | 在当前 session 执行 `cd <path>` |
| 默认显示 | 完整路径，如 `~/projects/myapp/src ▶` |

### 设置

通过 `defaults write` 调整，无需重新安装，下次点击即生效。

**路径显示段数**（A）

```bash
# 只显示最后 3 段：~/…/myapp/src ▶
defaults write io.github.iterm-cd max-path-segments -int 3

# 恢复完整路径（默认）
defaults delete io.github.iterm-cd max-path-segments
```

**点击后清屏**（B）

```bash
# cd 后自动执行 clear
defaults write io.github.iterm-cd clear-on-cd -bool true

# 关闭（默认）
defaults delete io.github.iterm-cd clear-on-cd
```

**点击动作**（C）

```bash
# 在当前 session 执行 cd（默认）
defaults write io.github.iterm-cd click-action -string cd

# 复制路径到剪贴板
defaults write io.github.iterm-cd click-action -string copy

# 在 Finder 中打开该目录
defaults write io.github.iterm-cd click-action -string finder
```

### 卸载

```bash
bash uninstall.sh
```

---

## 工具二：Finder 快速操作（cd to iTerm2）

在 Finder 中右键任意文件或文件夹，选择 `cd to iTerm2`，直接在 iTerm2 打开该目录。
类似 [cdto](https://github.com/jbtule/cdto)，但目标终端是 iTerm2。

### 安装

```bash
bash install.sh
```

自动完成：编译 App、安装到 `~/Applications`、安装 Quick Action、触发 Finder 权限授权弹窗。

### 首次授权（只需一次）

`install.sh` 运行后会自动弹出权限询问框：

1. 弹出「cd to iTerm2 想要访问 Finder」→ 点 **好**
2. 弹出「去授权」对话框 → 点 **去授权** → 自动跳转到系统设置自动操作页面
3. 在列表中找到 `cd to iTerm2` → 勾选 **Finder**

### 添加到 Finder 工具栏

1. 打开 Finder，按 **⇧⌘G** 输入 `~/Applications` 回车
2. 找到 `cd to iTerm2.app`，按住 **⌘** 拖到 Finder 工具栏

### 使用

**工具栏按钮**：点击后在 iTerm2 打开当前 Finder 目录

**右键菜单**：右键文件或文件夹 → Quick Actions → **cd to iTerm2**

### 使用

| 选中内容 | 效果 |
|----------|------|
| 选中文件夹 | 在 iTerm2 打开该文件夹 |
| 选中文件 | 在 iTerm2 打开文件所在目录 |
| 未选中（直接点工具栏） | 打开当前 Finder 窗口的目录 |

已有 iTerm2 窗口时新建 tab，没有窗口时新建 window。

### 卸载

```bash
rm -rf ~/Library/Services/"cd to iTerm2.workflow"
/System/Library/CoreServices/pbs -update
```

---

## 工作原理

**状态栏组件**：基于 [iTerm2 Python API](https://iterm2.com/python-api/)，注册自定义状态栏组件，读取 Shell Integration 写入的 `path` 变量，点击时向 session 发送 `cd <path>` 命令。

**Finder 快速操作**：Automator Quick Action（.workflow），接收 Finder 选中项，通过 AppleScript 控制 iTerm2 打开对应目录。

---

## 参考项目

- [cdto](https://github.com/jbtule/cdto) — Finder 工具栏 App，在 Terminal 中打开当前 Finder 目录

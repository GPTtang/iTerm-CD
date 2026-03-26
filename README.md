# iTerm CD To Current

为 iTerm2 提供两个"快速 cd 到目标目录"的工具，灵感来自 [cdto](https://github.com/jbtule/cdto)。

| 工具 | 入口 | 功能 |
|------|------|------|
| **Finder 工具栏 App** | Finder 工具栏按钮 / 右键菜单 | 在 Finder 浏览目录时，一键在 iTerm2 打开 |
| **iTerm2 状态栏组件** | iTerm2 状态栏 | 显示当前目录路径，点击在同一 session 执行 cd |

---

## 安装

**前提**：已安装 [iTerm2](https://iterm2.com/)

```bash
git clone https://github.com/your-username/iTerm-CD.git
cd iTerm-CD
bash install.sh
```

`install.sh` 自动完成所有步骤：

| 步骤 | 内容 |
|------|------|
| 1 | 安装 iTerm2 AutoLaunch 脚本（状态栏组件） |
| 2 | 安装 Shell Integration，让 iTerm2 追踪当前目录 |
| 3 | 启用 iTerm2 状态栏并添加 `cd to...` 组件 |
| 4 | 编译 `cd to iTerm2.app` 并安装到 `~/Applications`，同时安装 Finder Quick Action |
| 5 | 打开 iTerm2 Python Runtime 安装界面 |

---

## 工具一：Finder 工具栏 App

类似 cdto，在 Finder 中打开 iTerm2 到当前目录。

### 首次授权（只需一次）

`install.sh` 运行后会自动触发授权流程：

1. 弹出「cd to iTerm2 想要访问 Finder」→ 点 **好**
2. 弹出提示对话框 → 点 **去授权** → 自动跳转系统设置
3. 系统设置 → 隐私与安全 → 自动操作 → `cd to iTerm2` → 勾选 **Finder**

### 添加到 Finder 工具栏

1. Finder 中按 **⇧⌘G** → 输入 `~/Applications` → 回车
2. 找到 `cd to iTerm2.app`，按住 **⌘** 拖到 Finder 工具栏松手

### 使用

| 方式 | 操作 | 效果 |
|------|------|------|
| 工具栏 | 点击按钮 | 在 iTerm2 打开当前 Finder 窗口的目录 |
| 右键菜单 | 右键文件或文件夹 → Quick Actions → **cd to iTerm2** | 在 iTerm2 打开选中项所在目录 |

| 选中内容 | 打开的目录 |
|----------|-----------|
| 文件夹 | 该文件夹本身 |
| 文件 | 文件所在目录 |
| 无选中 | 当前 Finder 窗口的目录 |

已有 iTerm2 窗口时新建 tab，无窗口时新建 window。

### 卸载

```bash
rm -rf ~/Applications/"cd to iTerm2.app"
rm -rf ~/Library/Services/"cd to iTerm2.workflow"
/System/Library/CoreServices/pbs -update
```

---

## 工具二：iTerm2 状态栏组件

在 iTerm2 状态栏实时显示当前目录，点击执行 `cd`。

```
~/projects/myapp ▶
```

### 最后一步（只需一次）

`install.sh` 运行后，在 iTerm2 中完成 Python Runtime 安装：

**iTerm2 菜单 → Scripts → Manage → Install Python Runtime → 点 Install**

安装完成后重开一个 iTerm2 窗口，状态栏即出现路径显示。

### 使用

单击状态栏路径 → 在当前 session 执行 `cd <path>`

### 设置

通过 `defaults write` 调整行为，修改后下次点击即生效，无需重启。

**路径显示段数**

```bash
# 只显示最后 3 段，如 ~/…/myapp/src ▶
defaults write io.github.iterm-cd max-path-segments -int 3

# 恢复完整路径（默认）
defaults delete io.github.iterm-cd max-path-segments
```

**点击后清屏**

```bash
# cd 后自动执行 clear
defaults write io.github.iterm-cd clear-on-cd -bool true

# 关闭（默认）
defaults delete io.github.iterm-cd clear-on-cd
```

**点击动作**

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

## 项目结构

```
iTerm-CD/
├── install.sh                        # 一键安装
├── uninstall.sh                      # 卸载状态栏组件
├── finder-app/
│   ├── cd_to_iterm.applescript       # Finder 工具栏 App 源码
│   ├── cd_to_iterm.entitlements      # Apple Events 权限声明
│   └── build.sh                      # 编译 App
└── scripts/
    ├── iterm_cd_to_current.py        # iTerm2 状态栏组件
    ├── configure_statusbar.py        # 写入 iTerm2 状态栏配置
    └── build_workflow.py             # 生成 Finder Quick Action
```

---

## 参考项目

- [cdto](https://github.com/jbtule/cdto) — Finder 工具栏 App，在 Terminal 中打开当前 Finder 目录

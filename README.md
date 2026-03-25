# iTerm CD To Current

`iTerm CD To Current` 是一个面向 iTerm2 的小工具，用来把当前目录显示出来，并提供一个可点击的 `cd to ...` 入口，点一下就把当前 shell 切到该目录。

它适合这类场景：

- 你开了很多 tab / pane，想快速看清当前目录
- 你想在 iTerm2 里给当前 session 加一个明显的“回到当前目录”入口
- 你想把这个能力打包成 `.app`、`.pkg`、`.dmg` 发给别人直接用

## 功能

- 自动把当前目录同步到 session `badge`
- 提供 `Title Provider`，可把目录显示到 pane 顶部标题
- 提供可点击的 `Status Bar` 组件
- 点击后向当前 session 注入 `cd -- <current-path>`
- 支持命令行安装 / 卸载
- 支持 macOS `.app` / `.pkg` / `.dmg` 打包
- 支持 Developer ID 签名和 notarization 发布流程

## 原理

iTerm2 没有一个“固定在顶部且同时可点击”的单一控件，所以这个项目把能力拆开实现：

- 顶部显示：用 `badge` 或 `title`
- 点击交互：用 `Status Bar`

最终效果是：

- 顶部能看到当前目录
- 底部状态栏有一个 `cd to ...` 可点击按钮

## 依赖

- macOS
- iTerm2
- iTerm2 Python API
- iTerm2 Shell Integration

没有启用 Shell Integration 时，`session.path` 可能为空，脚本无法稳定拿到当前目录。

## 安装

### 方式 1：命令行安装

克隆仓库后执行：

```bash
git clone <your-repo-url>
cd iTerm-CD
./install.sh
```

如果你希望直接修改仓库里的脚本并立即生效，可以改用软链接模式：

```bash
./install.sh --link
```

### 方式 2：手动安装脚本

把 `scripts/iterm_cd_to_current.py` 放到：

```text
~/Library/Application Support/iTerm2/Scripts/AutoLaunch/
```

然后重启 iTerm2，或者在 `Scripts` 菜单里手动运行它。

### 方式 3：使用打包产物

如果你已经通过 `packaging/macos` 构建出发布文件，可以直接使用：

- `iTerm CD Installer.app`
- `iTerm CD Installer.pkg`
- `iTerm-CD-macOS.dmg`

对外分发时，通常优先使用：

- `.pkg`
- 或 `.dmg`

## 使用

### 开启状态栏按钮

在 iTerm2 中：

1. 打开 `Settings > Profiles > Session`
2. 开启 `Status bar enabled`
3. 点击 `Configure Status Bar`
4. 把 `CD To Current Directory` 拖进状态栏

之后状态栏会出现 `cd to ...`。点击后会发送：

```bash
cd -- '当前目录'
```

### 开启顶部目录显示

脚本会自动给 session 写入 `badge`，例如：

```text
cd to
/Users/you/project
```

如果你希望目录同时显示在 pane 顶部标题栏：

1. 打开 `Settings > Appearance`
2. 开启 `Show per-pane title bar with split panes`
3. 打开 `Settings > Profiles > General > Title`
4. 选择 `CD To Current Directory`

### 可选：绑定快捷键

脚本注册了一个 RPC：

```text
cd_to_current_directory()
```

你可以在 `Settings > Keys` 新增：

- Action: `Invoke Script Function`
- Function Call: `cd_to_current_directory()`

## 卸载

命令行卸载：

```bash
./uninstall.sh
```

或直接双击：

- `iTerm CD Uninstaller.app`

卸载时会：

- 删除 `AutoLaunch` 目录里的安装脚本
- 尝试清空当前已打开 session 的顶部 `badge`

完整清理通常还需要重启一次 iTerm2，因为状态栏组件和标题提供器是运行时注册的。

## 项目结构

```text
iTerm-CD/
├── assets/
│   └── macos/
│       ├── installer-icon.svg
│       └── uninstaller-icon.svg
├── docs/
│   └── macos-release.md
├── packaging/
│   └── macos/
│       ├── build_apps.sh
│       ├── build_dmg.sh
│       ├── build_icons.sh
│       ├── build_pkg.sh
│       ├── build_release.sh
│       ├── common.sh
│       ├── installer.js
│       ├── install_payload.sh
│       ├── pkg_postinstall.sh
│       ├── uninstall_payload.sh
│       ├── uninstaller.js
│       └── DMG-README.txt
├── scripts/
│   └── iterm_cd_to_current.py
├── .github/
│   └── workflows/
│       └── macos-release.yml
├── install.sh
├── uninstall.sh
└── README.md
```

## 构建

### 生成 `.app`

```bash
zsh packaging/macos/build_apps.sh
```

### 生成 `.pkg`

```bash
zsh packaging/macos/build_pkg.sh
```

### 生成 `.dmg`

```bash
zsh packaging/macos/build_dmg.sh
```

### 一次性生成全部产物

```bash
zsh packaging/macos/build_release.sh
```

## Developer ID 签名与 notarization

仓库已经预留了正式发布所需的流程：

- 自定义图标
- Developer ID Application 签名
- Developer ID Installer 签名
- `notarytool` 提交 notarization
- `stapler` 回写票据

本地发布说明见：`docs/macos-release.md`

GitHub Actions 发布流程见：`.github/workflows/macos-release.yml`

## 限制

- 当前只面向 macOS + iTerm2
- 依赖 iTerm2 Shell Integration 才能稳定获取当前目录
- “顶部显示”和“点击交互”是两套独立能力的组合，不是单一控件
- 未签名构建在别的机器上可能需要右键“打开”一次

## 提交到 GitHub 前建议

如果你准备正式开源，建议再补这些仓库级文件：

- `LICENSE`
- `CHANGELOG.md`
- 一张截图或录屏 GIF
- `CONTRIBUTING.md`

其中 `LICENSE` 最重要。没有许可证，别人默认没有明确的使用、修改和分发权限。

## 免责声明

这是一个基于 iTerm2 官方脚本能力实现的小工具，不隶属于 iTerm2 官方项目。

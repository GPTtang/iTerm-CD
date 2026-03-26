# iTerm CD To Current

在 macOS 上使用 iTerm2 时，经常遇到这两个场景：

- 在 Finder 里找到了某个目录，想立刻在终端里打开它
- 在 iTerm2 里开了很多 tab，想快速看清当前目录，或一键跳回某个路径

这个项目提供两个小工具，分别解决这两个问题。

---

## 工具一：Finder 工具栏 App

[![Download](https://img.shields.io/github/v/release/GPTtang/iTerm-CD?label=Download&logo=github)](https://github.com/GPTtang/iTerm-CD/releases/latest/download/cd-to-iTerm2.zip)

在 Finder 工具栏放一个按钮，点击后直接在 iTerm2 打开当前目录。

**下载安装**

1. 下载 [cd-to-iTerm2.zip](https://github.com/GPTtang/iTerm-CD/releases/latest/download/cd-to-iTerm2.zip) 并解压
2. 将 `cd to iTerm2.app` 复制到 `~/Applications`
3. 打开 Finder，按住 **⌘** 将 App 拖入 Finder 工具栏

**首次使用授权（只需一次）**

首次点击工具栏按钮时，macOS 会询问 Finder 访问权限：

1. 弹出权限询问框 → 点 **好**
2. 弹出「去授权」提示 → 点 **去授权** → 自动跳转系统设置
3. 系统设置 → 隐私与安全 → 自动操作 → `cd to iTerm2` → 勾选 **Finder**
4. 回到 Finder，再次点击工具栏按钮即可正常使用

**使用方式**

| 操作 | 效果 |
|------|------|
| 点击工具栏按钮 | 在 iTerm2 打开当前 Finder 窗口的目录 |
| 右键文件夹 → Quick Actions → cd to iTerm2 | 在 iTerm2 打开该文件夹 |
| 右键文件 → Quick Actions → cd to iTerm2 | 在 iTerm2 打开文件所在目录 |

已有 iTerm2 窗口时新建 tab，无窗口时新建 window。

---

## 工具二：iTerm2 状态栏组件

在 iTerm2 状态栏实时显示当前目录路径，点击执行 `cd`。

```
~/projects/myapp/src ▶
```

**安装**

需要已安装 [iTerm2](https://iterm2.com/)，然后运行：

```bash
git clone https://github.com/GPTtang/iTerm-CD.git
cd iTerm-CD
bash install.sh
```

安装完成后，在 iTerm2 中执行最后一步（只需一次）：

**Scripts → Manage → Install Python Runtime → 点 Install**

重开一个 iTerm2 窗口，状态栏即显示当前路径。

**使用方式**

单击状态栏路径 → 在当前 session 执行 `cd <path>`

**个性化设置**

通过 `defaults write` 调整，修改后立即生效。

```bash
# 路径过长时自动折叠，只显示最后 3 段
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

## 一键安装两个工具

```bash
git clone https://github.com/GPTtang/iTerm-CD.git
cd iTerm-CD
bash install.sh
```

`install.sh` 自动完成：安装状态栏组件、Shell Integration、Finder 工具栏 App、Quick Action，并触发首次权限授权。

---

## 致谢

本项目灵感来自 [cdto](https://github.com/jbtule/cdto)，感谢 [@jbtule](https://github.com/jbtule) 的出色工作。

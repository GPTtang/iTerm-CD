# iTerm CD To Current

**在 Finder 和 iTerm2 之间一键跳转目录。**

在 Finder 里找到目录后，不用手动复制路径、不用切换窗口输入 `cd`，直接点一下就在 iTerm2 里打开。

---

## 功能

| 方式 | 操作 | 效果 |
|------|------|------|
| Finder 工具栏按钮 | 点击工具栏上的 App | 在 iTerm2 打开当前 Finder 窗口目录 |
| 右键快速操作 | 右键文件或文件夹 → Quick Actions → cd to iTerm2 | 在 iTerm2 打开选中项所在目录 |

已有 iTerm2 窗口时新建 tab，无窗口时新建 window。

---

## 安装

### 方式一：下载预构建包（推荐）

在终端运行以下命令（**必须用 curl，不能用浏览器下载**，否则 Gatekeeper 会拦截）：

```bash
curl -L https://github.com/GPTtang/iTerm-CD/releases/latest/download/cd-to-iTerm2.zip -o /tmp/cd-to-iTerm2.zip \
  && ditto -x -k /tmp/cd-to-iTerm2.zip /tmp/cd-iterm2 \
  && cp -r "/tmp/cd-iterm2/cd to iTerm2.app" /Applications/ \
  && rm -rf /tmp/cd-to-iTerm2.zip /tmp/cd-iterm2 \
  && open -R /Applications/"cd to iTerm2.app"
```

命令执行完会自动在 Finder 中选中 App。

### 方式二：从源码构建

```bash
git clone https://github.com/GPTtang/iTerm-CD.git
cd iTerm-CD
bash install.sh
```

> 需要已安装 iTerm2 和 Xcode Command Line Tools。

---

## 添加到 Finder 工具栏

安装完成后，按住 **⌘（Command）**，将 `/Applications/cd to iTerm2.app` 拖入 Finder 工具栏。

---

## 首次授权（只需一次）

首次点击工具栏按钮时，macOS 会请求 Finder 访问权限：

1. 弹出权限询问框 → 点 **好**
2. 如出现「去授权」提示 → 点 **去授权** → 自动跳转系统设置
3. 系统设置 → 隐私与安全性 → 自动操作 → `cd to iTerm2` → 勾选 **Finder**
4. 回到 Finder，再次点击工具栏按钮即可正常使用

---

## 卸载

```bash
# 从源码目录运行
bash uninstall.sh
```

或手动删除：
- `/Applications/cd to iTerm2.app`
- `~/Library/Services/cd to iTerm2.workflow`

---

## 致谢

本项目灵感来自 [cdto](https://github.com/jbtule/cdto)，感谢 [@jbtule](https://github.com/jbtule) 的出色工作。

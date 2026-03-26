# iTerm CD To Current

**在 Finder 和 iTerm2 之间快速跳转目录。**

| 场景 | 解决方式 |
|------|---------|
| 在 Finder 里找到某个目录，想立刻用终端打开 | 点工具栏按钮，直接在 iTerm2 打开 |
| 右键文件或文件夹，想快速在终端里进入 | 右键 → Quick Actions → cd to iTerm2 |

---

## 安装

在终端运行：

```bash
curl -L https://github.com/GPTtang/iTerm-CD/releases/latest/download/cd-to-iTerm2.zip -o /tmp/cd-to-iTerm2.zip \
  && ditto -x -k /tmp/cd-to-iTerm2.zip /tmp/cd-iterm2 \
  && cp -r "/tmp/cd-iterm2/cd to iTerm2.app" /Applications/ \
  && rm -rf /tmp/cd-to-iTerm2.zip /tmp/cd-iterm2 \
  && open -R /Applications/"cd to iTerm2.app"
```

命令执行完会自动打开 Finder 并选中 App，按住 **⌘** 拖入工具栏即可。

---

## 首次授权（只需一次）

首次点击工具栏按钮时，macOS 会请求 Finder 访问权限：

1. 弹出权限询问框 → 点 **好**
2. 弹出「去授权」提示 → 点 **去授权** → 自动跳转系统设置
3. 系统设置 → 隐私与安全 → 自动操作 → `cd to iTerm2` → 勾选 **Finder**
4. 回到 Finder，再次点击工具栏按钮即可正常使用

---

## 使用

| 操作 | 效果 |
|------|------|
| 点击工具栏按钮 | 在 iTerm2 打开当前 Finder 窗口的目录 |
| 右键 → Quick Actions → cd to iTerm2 | 在 iTerm2 打开选中的文件夹 |

已有 iTerm2 窗口时新建 tab，无窗口时新建 window。

---

## 卸载

```bash
bash uninstall.sh
```

---

## 致谢

本项目灵感来自 [cdto](https://github.com/jbtule/cdto)，感谢 [@jbtule](https://github.com/jbtule) 的出色工作。

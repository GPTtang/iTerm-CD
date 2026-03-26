# iTerm CD To Current

**Jump instantly from Finder to iTerm2.**

[English](#english) · [日本語](#日本語) · [中文](#中文)

---

## English

Open the current Finder directory in iTerm2 with a single click — no more manually typing `cd /long/nested/path`.

### Features

| Method | Action | Result |
|--------|--------|--------|
| Finder toolbar button | Click the button | Opens current Finder window directory in iTerm2 |
| Right-click Quick Action | Right-click file or folder → Quick Actions → cd to iTerm2 | Opens the selected item's directory in iTerm2 |

Creates a new tab if an iTerm2 window already exists, otherwise opens a new window.

### Install

Run in terminal (**must use curl, not browser download** — browser adds Gatekeeper quarantine):

```bash
curl -L https://github.com/GPTtang/iTerm-CD/releases/latest/download/cd-to-iTerm2.zip -o /tmp/cd-to-iTerm2.zip \
  && ditto -x -k /tmp/cd-to-iTerm2.zip /tmp/cd-iterm2 \
  && cp -r "/tmp/cd-iterm2/cd to iTerm2.app" /Applications/ \
  && rm -rf /tmp/cd-to-iTerm2.zip /tmp/cd-iterm2 \
  && open -R /Applications/"cd to iTerm2.app"
```

The command finishes by revealing the app in Finder.

**Or build from source:**

```bash
git clone https://github.com/GPTtang/iTerm-CD.git
cd iTerm-CD
bash install.sh
```

### Add to Finder Toolbar

Hold **⌘ (Command)** and drag `/Applications/cd to iTerm2.app` into the Finder toolbar.

### First-time Authorization (once only)

1. Click the toolbar button — macOS will prompt for Finder access
2. Click **OK** on the permission dialog
3. If prompted with "Open Settings" → click it → System Settings opens automatically
4. System Settings → Privacy & Security → Automation → `cd to iTerm2` → enable **Finder**
5. Click the toolbar button again — it works

### Uninstall

```bash
bash uninstall.sh
```

The script automatically removes the toolbar button, the app, the Quick Action, and restarts Finder.

---

## 日本語

Finder の現在のディレクトリをワンクリックで iTerm2 で開きます。`cd /long/path` を手入力する手間をなくします。

### 機能

| 方法 | 操作 | 結果 |
|------|------|------|
| Finder ツールバーボタン | ボタンをクリック | 現在の Finder ウィンドウのディレクトリを iTerm2 で開く |
| 右クリック クイックアクション | ファイル/フォルダを右クリック → クイックアクション → cd to iTerm2 | 選択した項目のディレクトリを iTerm2 で開く |

iTerm2 ウィンドウが既にある場合は新しいタブ、ない場合は新しいウィンドウを開きます。

### インストール

ターミナルで実行してください（**ブラウザダウンロードは不可** — Gatekeeper の検疫が付与されるため、必ず curl を使用）：

```bash
curl -L https://github.com/GPTtang/iTerm-CD/releases/latest/download/cd-to-iTerm2.zip -o /tmp/cd-to-iTerm2.zip \
  && ditto -x -k /tmp/cd-to-iTerm2.zip /tmp/cd-iterm2 \
  && cp -r "/tmp/cd-iterm2/cd to iTerm2.app" /Applications/ \
  && rm -rf /tmp/cd-to-iTerm2.zip /tmp/cd-iterm2 \
  && open -R /Applications/"cd to iTerm2.app"
```

**ソースからビルドする場合：**

```bash
git clone https://github.com/GPTtang/iTerm-CD.git
cd iTerm-CD
bash install.sh
```

### Finder ツールバーへの追加

**⌘ (Command)** を押しながら `/Applications/cd to iTerm2.app` を Finder ツールバーにドラッグします。

### 初回の権限許可（一度だけ）

1. ツールバーボタンをクリック — macOS が Finder へのアクセス許可を求めます
2. 権限ダイアログで **OK** をクリック
3. 「設定を開く」と表示された場合 → クリック → システム設定が自動で開きます
4. システム設定 → プライバシーとセキュリティ → 自動操作 → `cd to iTerm2` → **Finder** を有効にする
5. ツールバーボタンを再度クリック — 正常に動作します

### アンインストール

```bash
bash uninstall.sh
```

スクリプトはツールバーボタン、アプリ、クイックアクションを自動で削除し、Finder を再起動します。

---

## 中文

一键从 Finder 跳转到 iTerm2，不再手动输入 `cd /long/nested/path`。

### 功能

| 方式 | 操作 | 效果 |
|------|------|------|
| Finder 工具栏按钮 | 点击按钮 | 在 iTerm2 打开当前 Finder 窗口目录 |
| 右键快速操作 | 右键文件或文件夹 → Quick Actions → cd to iTerm2 | 在 iTerm2 打开选中项所在目录 |

已有 iTerm2 窗口时新建 tab，无窗口时新建 window。

### 安装

在终端运行（**必须用 curl，不能用浏览器下载** — 浏览器会添加 Gatekeeper 隔离标记）：

```bash
curl -L https://github.com/GPTtang/iTerm-CD/releases/latest/download/cd-to-iTerm2.zip -o /tmp/cd-to-iTerm2.zip \
  && ditto -x -k /tmp/cd-to-iTerm2.zip /tmp/cd-iterm2 \
  && cp -r "/tmp/cd-iterm2/cd to iTerm2.app" /Applications/ \
  && rm -rf /tmp/cd-to-iTerm2.zip /tmp/cd-iterm2 \
  && open -R /Applications/"cd to iTerm2.app"
```

命令执行完会自动在 Finder 中选中 App。

**从源码构建：**

```bash
git clone https://github.com/GPTtang/iTerm-CD.git
cd iTerm-CD
bash install.sh
```

### 添加到 Finder 工具栏

按住 **⌘（Command）**，将 `/Applications/cd to iTerm2.app` 拖入 Finder 工具栏。

### 首次授权（只需一次）

1. 点击工具栏按钮 — macOS 会请求 Finder 访问权限
2. 权限弹窗中点 **好**
3. 如出现「去授权」提示 → 点击 → 自动跳转系统设置
4. 系统设置 → 隐私与安全性 → 自动操作 → `cd to iTerm2` → 勾选 **Finder**
5. 再次点击工具栏按钮即可正常使用

### 卸载

```bash
bash uninstall.sh
```

脚本会自动移除工具栏按钮、App、Quick Action，并重启 Finder。

---

## Credits

Inspired by [cdto](https://github.com/jbtule/cdto) — thanks to [@jbtule](https://github.com/jbtule) for the great work.

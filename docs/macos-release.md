# macOS 正式发布

这份说明对应仓库里的 macOS 打包脚本，目标是生成：

- 带自定义图标的 `.app`
- 使用 Developer ID 签名的 `.app` / `.pkg` / `.dmg`
- 已通过 notarization 并 stapled 的最终分发产物

## 需要准备的东西

### 1. Apple Developer 账号

你需要有效的 Apple Developer Program 账号，以及：

- `Developer ID Application` 证书
- `Developer ID Installer` 证书

Apple 官方说明：

- https://developer.apple.com/help/account/certificates/create-developer-id-certificates
- https://developer.apple.com/developer-id/
- https://developer.apple.com/documentation/security/customizing-the-notarization-workflow

### 2. 本机钥匙串里可用的证书

在本机安装好这两个证书后，先确认 `Keychain Access` 里能看到：

- `Developer ID Application: ...`
- `Developer ID Installer: ...`

### 3. notarytool 凭证

推荐先把 notarytool 凭证保存成 keychain profile：

```bash
xcrun notarytool store-credentials "iterm-cd-notary" \
  --apple-id "YOUR_APPLE_ID" \
  --team-id "YOUR_TEAM_ID" \
  --password "YOUR_APP_SPECIFIC_PASSWORD"
```

之后构建脚本里只需要传：

```bash
export NOTARYTOOL_PROFILE="iterm-cd-notary"
```

## 环境变量

```bash
export RELEASE_VERSION="1.0.0"
export ENABLE_SIGNING="1"
export ENABLE_NOTARIZATION="1"
export DEVELOPER_ID_APPLICATION="Developer ID Application: Your Name (TEAMID)"
export DEVELOPER_ID_INSTALLER="Developer ID Installer: Your Name (TEAMID)"
export NOTARYTOOL_PROFILE="iterm-cd-notary"
```

如果你把证书放在非默认钥匙串，还可以额外传：

```bash
export CODESIGN_KEYCHAIN="/path/to/your.keychain-db"
```

## 构建命令

### 只构建带图标的 `.app`

```bash
./packaging/macos/build_apps.sh
```

如果启用了签名和公证，这一步还会：

- 签名两个 `.app`
- 提交 notarization
- 对 `.app` 执行 staple
- 输出可分发的 zip

### 构建 `.pkg`

```bash
./packaging/macos/build_pkg.sh
```

### 构建 `.dmg`

```bash
./packaging/macos/build_dmg.sh
```

### 一次性全部构建

```bash
./packaging/macos/build_release.sh
```

## 产物

默认输出目录：

```text
dist/macos/
```

会包含：

- `iTerm CD Installer.app`
- `iTerm CD Uninstaller.app`
- `iTerm CD Installer.pkg`
- `iTerm-CD-macOS.dmg`

如果启用了 app notarization，还会额外生成：

- `iTerm CD Installer.zip`
- `iTerm CD Uninstaller.zip`

## 验证建议

签名后可手动检查：

```bash
codesign --verify --deep --strict --verbose=2 "dist/macos/iTerm CD Installer.app"
pkgutil --check-signature "dist/macos/iTerm CD Installer.pkg"
spctl -a -vv --type execute "dist/macos/iTerm CD Installer.app"
spctl -a -vv --type install "dist/macos/iTerm CD Installer.pkg"
```

## 说明

- `.app` 使用自定义图标，源文件在 `assets/macos/*.svg`
- `.pkg` 使用 `Developer ID Installer` 证书签名
- `.dmg` 使用 `Developer ID Application` 证书签名并可提交 notarization
- notarization 依赖 `notarytool` 的 keychain profile

## GitHub Actions

仓库里已经附带一份 macOS 发布工作流：

```text
.github/workflows/macos-release.yml
```

它会在：

- 手动触发 `workflow_dispatch`
- 推送 `v*` tag

时自动执行：

- 导入 Developer ID 证书
- 创建临时 keychain
- 保存 notarytool 凭证
- 构建签名并公证过的 `.app` / `.pkg` / `.dmg`
- 上传构建产物
- 在 tag 发布时附加到 GitHub Release

你需要在 GitHub Secrets 里准备：

- `MACOS_DEVELOPER_ID_APPLICATION_P12`
- `MACOS_DEVELOPER_ID_APPLICATION_P12_PASSWORD`
- `MACOS_DEVELOPER_ID_INSTALLER_P12`
- `MACOS_DEVELOPER_ID_INSTALLER_P12_PASSWORD`
- `MACOS_DEVELOPER_ID_APPLICATION_NAME`
- `MACOS_DEVELOPER_ID_INSTALLER_NAME`
- `MACOS_KEYCHAIN_PASSWORD`
- `MACOS_APPLE_ID`
- `MACOS_TEAM_ID`
- `MACOS_APP_SPECIFIC_PASSWORD`

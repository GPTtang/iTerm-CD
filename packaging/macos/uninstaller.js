ObjC.import("Foundation");

const app = Application.currentApplication();
app.includeStandardAdditions = true;

const bundlePath = ObjC.unwrap($.NSBundle.mainBundle.bundlePath);
const shellScriptPath = `${bundlePath}/Contents/Resources/uninstall_payload.sh`;

try {
  const resultText = app.doShellScript(shellScriptPath);
  app.displayDialog(resultText, {
    buttons: ["确定"],
    defaultButton: "确定",
  });
} catch (error) {
  app.displayDialog(`卸载失败\n\n${error}`, {
    buttons: ["确定"],
    defaultButton: "确定",
    withIcon: "stop",
  });
}

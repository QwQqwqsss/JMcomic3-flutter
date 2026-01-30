import { FlutterAbility, FlutterEngine, MethodCall, MethodChannel, MethodResult } from '@ohos/flutter_ohos';
import { GeneratedPluginRegistrant } from '../plugins/GeneratedPluginRegistrant';
import { init, invoke } from 'librust.so'
import { hilog } from '@kit.PerformanceAnalysisKit';
import { fileIo as fs, ReadOptions } from '@kit.CoreFileKit'

export default class EntryAbility extends FlutterAbility {
  configureFlutterEngine(flutterEngine: FlutterEngine) {

    this.printDir();

    init(this.context.filesDir)

    new MethodChannel(flutterEngine.dartExecutor.getBinaryMessenger(), "methods")
      .setMethodCallHandler(this)

    super.configureFlutterEngine(flutterEngine)
    GeneratedPluginRegistrant.registerWith(flutterEngine)
  }

  async printDir(){
    hilog.warn(0, 'configureFlutterEngine', '%{public}s', "===============");
    hilog.warn(0, 'configureFlutterEngine', '%{public}s', "dir : " + this.context.filesDir);
    let files = await fs.listFile(this.context.filesDir)
    for (let filesElement of files) {
      hilog.warn(0, 'configureFlutterEngine', '%{public}s', "file : " + filesElement);
    }
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    hilog.warn(0, 'onMethodCall', '%{public}s', call.method);
    hilog.warn(0, 'onMethodCall', '%{public}s', call.args);
    switch (call.method) {
      case 'invoke':
        invoke(call.args).then((invokeResult) => {
          result.success(invokeResult)
        })
        break;
    }
  }
}

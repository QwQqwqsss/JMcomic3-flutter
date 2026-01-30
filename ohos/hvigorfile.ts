import { appTasks, OhosAppContext, OhosPluginId } from '@ohos/hvigor-ohos-plugin';
import { hvigor,getNode } from '@ohos/hvigor';
const fs = require("fs");

function loadSigningConfigs() {
    const path = 'signingConfigs.json';
    try {
        fs.accessSync(path);
    } catch (e) {
        if (e.code !== 'ENOENT') {
            log.error(e);
        }
        return [];
    }
    const data = fs.readFileSync(path);
    return JSON.parse(data);
}

const rootNode = getNode(__filename);
rootNode.afterNodeEvaluate(node => {
    const appContext = node.getContext(OhosPluginId.OHOS_APP_PLUGIN) as OhosAppContext;
    const buildProfileOpt = appContext.getBuildProfileOpt();
    if (!buildProfileOpt['app']['signingConfigs'] || buildProfileOpt['app']['signingConfigs'].length == 0) {
        buildProfileOpt['app']['signingConfigs'] = loadSigningConfigs();
    }
    appContext.setBuildProfileOpt(buildProfileOpt);
})

export default {
    system: appTasks,  /* Built-in plugin of Hvigor. It cannot be modified. */
    plugins:[]         /* Custom plugin to extend the functionality of Hvigor. */
}
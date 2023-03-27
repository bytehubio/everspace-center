"use strict";
exports.__esModule = true;
var fs = require("fs");
var ton3_1 = require("ton3");
function main() {
    var cfgb64File = process.argv[2];
    var configParam = parseInt(process.argv[3], 10); // 0 - 32
    var cfgb64 = fs.readFileSync(cfgb64File, { encoding: 'utf-8' });
    var cs = ton3_1.BOC.fromStandard(cfgb64).slice();
    var cfgDict = cs.loadRef();
    var deserializers = {
        key: function (key) { return new ton3_1.Builder()
            .storeBits(key)
            .cell()
            .slice()
            .preloadUint(32); },
        value: function (value) { return value; }
    };
    var dict = ton3_1.Hashmap.parse(32, cfgDict.slice(), { deserializers: deserializers });
    var paramBOC = '';
    dict.forEach(function (k, v) { if (k === configParam)
        paramBOC = ton3_1.BOC.toBase64Standard(v); });
    process.stdout.write(JSON.stringify({ param: configParam, boc: paramBOC }));
}
main();

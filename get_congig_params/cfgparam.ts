import * as fs from 'fs'
import { Bit, BOC, Builder, Cell, Hashmap } from 'ton3'

function main () {
    const cfgb64File = process.argv[2]
    const configParam = parseInt(process.argv[3], 10) // 0 - 32

    const cfgb64 = fs.readFileSync(cfgb64File, { encoding: 'utf-8' })
    const cs = BOC.fromStandard(cfgb64).slice()
    const cfgDict = cs.loadRef()

    const deserializers = {
        key: (key: Bit[]): number => new Builder()
            .storeBits(key)
            .cell()
            .slice()
            .preloadUint(32),
        value: (value: Cell) => value
    }

    const dict = Hashmap.parse<number, Cell>(32, cfgDict.slice(), { deserializers })

    let paramBOC = ''
    dict.forEach((k, v) => { if (k === configParam) paramBOC = BOC.toBase64Standard(v) })

    process.stdout.write(JSON.stringify({ param: configParam, boc: paramBOC }))
}

main()

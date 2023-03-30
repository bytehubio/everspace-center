import Vapor
import Swiftgger

var env = try Environment.detect()
try LoggingSystem.bootstrap(from: &env)
let evetnLoop: EventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount * 4)
let app: Application = .init(env, Application.EventLoopGroupProvider.shared(evetnLoop))
/// CLIENTS
let EverClient: SDKClientPrtcl = try SDKClient(clientConfig: SDKClient.makeClientConfig(name: "everscale_mainnet"))
let EverDevClient: SDKClientPrtcl = try SDKClient(clientConfig: SDKClient.makeClientConfig(name: "everscale_devnet"))
let RfldClient: SDKClientPrtcl = try SDKClient(clientConfig: SDKClient.makeClientConfig(["https://rfld-dapp.itgold.io"]))

let TonClient: SDKClientPrtcl = try SDKClient(clientConfig: SDKClient.makeClientConfig(name: "toncoin_mainnet"))


defer { app.shutdown() }
try configure(app)
try app.run()

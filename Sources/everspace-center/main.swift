import Vapor
import Swiftgger
import EverscaleClientSwift

var env = try Environment.detect()
try LoggingSystem.bootstrap(from: &env)
let evetnLoop: EventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount * 4)
let app: Application = .init(env, Application.EventLoopGroupProvider.shared(evetnLoop))
let sdkClientActor = SDKClientActor()


defer { app.shutdown() }
try await configure(app)
let everClient: TSDKClientModule = try SDKClient.makeClient(apiKey: "b17a652df5d642a6aa6e9dae4601685a", network: EVERSCALE_SDK_DOMAIN_ENV)
let everDevClient: TSDKClientModule = try SDKClient.makeClient(apiKey: "b17a652df5d642a6aa6e9dae4601685a", network: EVERSCALE_DEVNET_SDK_DOMAIN_ENV)
let everFLDClient: TSDKClientModule = try SDKClient.makeClient(apiKey: "b17a652df5d642a6aa6e9dae4601685a", network: EVERSCALE_RFLD_SDK_DOMAIN_ENV)
let everVenomClient: TSDKClientModule = try SDKClient.makeClient(apiKey: "b17a652df5d642a6aa6e9dae4601685a", network: VENOM_SDK_DOMAIN_ENV)
let everVenomTestnetClient: TSDKClientModule = try SDKClient.makeClient(apiKey: "b17a652df5d642a6aa6e9dae4601685a", network: VENOM_TESTNET_SDK_DOMAIN_ENV)
let everVenomDevnetClient: TSDKClientModule = try SDKClient.makeClient(apiKey: "b17a652df5d642a6aa6e9dae4601685a", network: VENOM_DEVNET_SDK_DOMAIN_ENV)
let everToncoinClient: TSDKClientModule = try SDKClient.makeClient(apiKey: "b17a652df5d642a6aa6e9dae4601685a", network: TONCOIN_SDK_DOMAIN_ENV)
let everToncoinTestnetClient: TSDKClientModule = try SDKClient.makeClient(apiKey: "b17a652df5d642a6aa6e9dae4601685a", network: TONCOIN_TESTNET_SDK_DOMAIN_ENV)

try app.run()

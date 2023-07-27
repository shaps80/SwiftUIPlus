import SwiftUI
import SwiftUIBackports

#if canImport(WebKit)
import WebKit
#endif

#if os(iOS)

#if canImport(SwiftUIBackports)
import SwiftUIBackports
#endif

internal struct WebView: View {
    @Environment(\.backportDismiss) private var dismiss
    @Environment(\.backportOpenURL) private var openUrl
    @Environment(\.self) private var environment
    @Binding var url: URL

    @State private var height: CGFloat = 0

    public init(url: Binding<URL>) {
        _url = url
    }

    public var body: some View {
        NavigationView {
            Representable(host: self)
                .edgesIgnoringSafeArea(.all)
                .descendent(forType: UIViewController.self) { proxy in
                    let controller = proxy.instance
                    controller.additionalSafeAreaInsets.bottom = height
                }
                .backport.overlay(alignment: .bottom) {
                    navigationBar
                }
                .backport.scrollDismissesKeyboard(.immediately)
                .ignoreKeyboard()
                .navigationBarTitle(Text("Web View"), displayMode: .inline)
                .backport.toolbar {
                    Backport.ToolbarItem(placement: .cancellationAction) {
                        Button("Close") { dismiss() }
                    }
                }
        }
        .navigationViewStyle(.stack)
    }

    enum Field: Hashable {
        case textField
    }

    private static let defaultPlaceholder: String = "Enter a website"
    private var alignment: HorizontalAlignment {
        field == nil ? .center : .leading
    }

    @State private var text: String = ""
    @State private var placeholder: String = Self.defaultPlaceholder
    @State private var progress: CGFloat = 0
    @State private var navigationState: NavigationState = .idle

    @Backport.FocusState private var field: Field?

    enum NavigationState {
        case idle
        case loading
    }

    private var navigationBar: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            HStack(alignment: .firstTextBaseline, spacing: 30) {
                Button { } label: {
                    Image(systemName: "chevron.left")
                        .highlightEffect()
                }
                .disabled(true)

                Button { } label: {
                    Image(systemName: "chevron.right")
                        .highlightEffect()
                }
                .disabled(true)
            }
            .font(.body.weight(.medium))

            Spacer(minLength: 0)

            Button {
                progress = 0
                withAnimation { navigationState = .loading }
                withAnimation(.easeIn(duration: 1)) {
                    progress = 1
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                    withAnimation(.spring()) {
                        navigationState = .idle
                    }
                }
            } label: {
                HStack(alignment: .firstTextBaseline) {
                    Image(systemName: navigationState == .loading ? "xmark.circle.fill" : "arrow.clockwise")
                        .imageScale(.small)
                        .frame(width: 16)

                    Text(url.host ?? url.absoluteString)
                        .lineLimit(1)
                        .font(.callout)
                }
                .foregroundColor(.primary)
                .highlightEffect()
            }
            .backport.background {
                GeometryReader { geo in
                    Capsule(style: .continuous)
                        .foregroundColor(.accentColor)
                        .frame(width: geo.size.width * progress, alignment: .leading)
                }
                .opacity(1 - progress)
            }
            .clipShape(Capsule(style: .continuous))
            .buttonStyle(.refresh)

            Spacer(minLength: 0)

            HStack(alignment: .firstTextBaseline, spacing: 30) {
                Backport.ShareLink(item: url) {
                    Image(systemName: "square.and.arrow.up")
                }
                .highlightEffect()

                Button {
                    openUrl(url)
                } label: {
                    Image(systemName: "safari")
                }
                .highlightEffect()
                .environment(\.backportOpenURL, .init { url in
                    .systemAction
                })
            }
        }
        .imageScale(.large)
        .padding(.vertical, 12)
        .padding(.horizontal)
        .backport.background {
            Rectangle()
                .edgesIgnoringSafeArea(.all)
                .onFrameChange { frame in
                    height = frame.height
                }
                .vibrantForeground()
                .backport.overlay(alignment: .top) {
                    Divider()
                }
        }
    }
}

extension ButtonStyle where Self == RefreshButtonStyle {
    static var refresh: Self { .init() }
}

struct RefreshButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .backport.background {
                Capsule(style: .continuous)
                    .foregroundColor(.primary.opacity(configuration.isPressed ? 0.2 : 0.1))
            }
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.spring(response: 0.2), value: configuration.isPressed)
    }
}

extension View {
    @ViewBuilder
    func highlightEffect() -> some View {
        if #available(iOS 15, *) {
            contentShape(.hoverEffect, RoundedRectangle(cornerRadius: 13, style: .continuous).inset(by: -20))
                .hoverEffect(.highlight)
        } else if #available(iOS 14, *) {
            hoverEffect(.highlight)
        } else {
            self
        }
    }

    @ViewBuilder
    func ignoreKeyboard() -> some View {
        if #available(iOS 14, *) {
            ignoresSafeArea(.keyboard, edges: .all)
        } else {
            self
        }
    }

    @ViewBuilder
    func vibrantForeground(thick: Bool = false) -> some View {
        if #available(iOS 15, *) {
            foregroundStyle(thick ? .ultraThickMaterial : .bar)
        } else {
            foregroundColor(Color(.systemBackground))
        }
    }
}

private struct Representable: UIViewControllerRepresentable {
    let host: WebView

    func makeUIViewController(context: Context) -> WebController {
        WebController(host: host)
    }

    func updateUIViewController(_ controller: WebController, context: Context) {
        controller.update(host: host)
    }
}

private final class WebController: UIViewController {
    private var host: WebView

    lazy var webView: WKWebView = {
        WKWebView(frame: .zero)
    }()

    init(host: WebView) {
        self.host = host
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(host: WebView) {
        self.host = host
    }

    override func loadView() {
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        edgesForExtendedLayout = .all

        webView.load(URLRequest(url: host.url))
        webView.layer.rasterizationScale = UIScreen.mainScreen.scale
        webView.layer.shouldRasterize = true
        webView.configuration.ignoresViewportScaleLimits = true
        webView.allowsBackForwardNavigationGestures = true
    }
}

struct WebVIew_Previews: PreviewProvider {
    static var previews: some View {
//        WebView(url: .constant(URL(string: "https://benkau.com")!))
        WebView(url: .constant(URL(string: "https://github.com/shaps80/SwiftUIBackports")!))
            .navigationBarTitle(Text("Web View"), displayMode: .inline)
            .preferredColorScheme(.dark)
            .accentColor(.green)
    }
}

#endif

import UIKit

final class HomeViewController: UIViewController {
    private let infoLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Nosmai × WebRTC"
        view.backgroundColor = .systemBackground

        let heading = UILabel()
        heading.text = "Live Streaming Demo"
        heading.font = .systemFont(ofSize: 28, weight: .bold)
        heading.textAlignment = .center

        infoLabel.font = .systemFont(ofSize: 14)
        infoLabel.textColor = .secondaryLabel
        infoLabel.textAlignment = .center
        infoLabel.numberOfLines = 0

        let hostButton = makeButton(title: "Go Live (Host)", color: .systemPink, action: #selector(goLive))
        let watchButton = makeButton(title: "Watch (Audience)", color: .systemIndigo, action: #selector(watch))

        let stack = UIStackView(arrangedSubviews: [heading, infoLabel, hostButton, watchButton])
        stack.axis = .vertical
        stack.spacing = 16
        stack.setCustomSpacing(32, after: infoLabel)
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            hostButton.heightAnchor.constraint(equalToConstant: 54),
            watchButton.heightAnchor.constraint(equalToConstant: 54),
        ])

        switch DemoConfig.load() {
        case .success(let config):
            infoLabel.text = "Room: \(config.roomName)\nBoth phones must be on the same Wi-Fi."
        case .failure(let error):
            infoLabel.text = error.message
            infoLabel.textColor = .systemRed
        }
    }

    #if DEBUG
    /// Debug builds only: launching with `-autoRole host` or `-autoRole audience`
    /// skips the home screen, so the demo can be started from the command line.
    private var didAutoOpen = false

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !didAutoOpen else { return }
        didAutoOpen = true
        switch UserDefaults.standard.string(forKey: "autoRole") {
        case "host": open(role: .host)
        case "audience": open(role: .audience)
        default: break
        }
    }
    #endif

    private func makeButton(title: String, color: UIColor, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = color
        button.layer.cornerRadius = 14
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    @objc private func goLive() { open(role: .host) }
    @objc private func watch() { open(role: .audience) }

    private func open(role: LiveViewController.Role) {
        switch DemoConfig.load() {
        case .success(let config):
            navigationController?.pushViewController(LiveViewController(role: role, config: config), animated: true)
        case .failure(let error):
            let alert = UIAlertController(title: "Config needed", message: error.message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
}

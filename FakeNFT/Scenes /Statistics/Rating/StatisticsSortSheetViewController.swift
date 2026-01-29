import UIKit

final class StatisticsSortSheetViewController: UIViewController {

    // MARK: - Public

    var onSelect: ((StatisticsSortOption) -> Void)?

    // MARK: - Private

    private let current: StatisticsSortOption

    private let dimView = UIView()
    private let sheetView = UIView()

    private let titleLabel = UILabel()

    private let optionsContainer = UIView()
    private let nameButton = UIButton(type: .system)
    private let ratingButton = UIButton(type: .system)

    private let closeButton = UIButton(type: .system)

    private var sheetBottomConstraint: NSLayoutConstraint?

    // MARK: - Init

    init(current: StatisticsSortOption) {
        self.current = current
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLayout()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateIn()
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = .clear

        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        dimView.alpha = 0
        dimView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dimView)
        dimView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closeTapped)))

        sheetView.backgroundColor = UIColor(named: "nftLightGray") ?? .systemGray6
        sheetView.layer.cornerRadius = 16
        sheetView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        sheetView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sheetView)

        titleLabel.textAlignment = .center
        titleLabel.textColor = .secondaryLabel
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        sheetView.addSubview(titleLabel)

        let p = NSMutableParagraphStyle()
        p.minimumLineHeight = 20
        p.maximumLineHeight = 20
        titleLabel.attributedText = NSAttributedString(
            string: "Сортировка",
            attributes: [
                .font: UIFont.systemFont(ofSize: 15, weight: .regular),
                .paragraphStyle: p,
                .kern: -0.24
            ]
        )

        optionsContainer.backgroundColor = UIColor(named: "nftLightGray") ?? .systemGray5
        optionsContainer.layer.cornerRadius = 12
        optionsContainer.clipsToBounds = true
        optionsContainer.translatesAutoresizingMaskIntoConstraints = false
        sheetView.addSubview(optionsContainer)

        configureOptionButton(nameButton, title: "По имени")
        configureOptionButton(ratingButton, title: "По рейтингу")

        nameButton.addTarget(self, action: #selector(nameTapped), for: .touchUpInside)
        ratingButton.addTarget(self, action: #selector(ratingTapped), for: .touchUpInside)

        let separator = UIView()
        separator.backgroundColor = UIColor.black.withAlphaComponent(0.12)
        separator.translatesAutoresizingMaskIntoConstraints = false
        optionsContainer.addSubview(separator)

        NSLayoutConstraint.activate([
            nameButton.topAnchor.constraint(equalTo: optionsContainer.topAnchor),
            nameButton.leadingAnchor.constraint(equalTo: optionsContainer.leadingAnchor),
            nameButton.trailingAnchor.constraint(equalTo: optionsContainer.trailingAnchor),
            nameButton.heightAnchor.constraint(equalToConstant: 56),

            separator.topAnchor.constraint(equalTo: nameButton.bottomAnchor),
            separator.leadingAnchor.constraint(equalTo: optionsContainer.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: optionsContainer.trailingAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1),

            ratingButton.topAnchor.constraint(equalTo: separator.bottomAnchor),
            ratingButton.leadingAnchor.constraint(equalTo: optionsContainer.leadingAnchor),
            ratingButton.trailingAnchor.constraint(equalTo: optionsContainer.trailingAnchor),
            ratingButton.heightAnchor.constraint(equalToConstant: 56),
            ratingButton.bottomAnchor.constraint(equalTo: optionsContainer.bottomAnchor)
        ])

        closeButton.setTitle("Закрыть", for: .normal)
        closeButton.setTitleColor(.systemBlue, for: .normal)
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        closeButton.backgroundColor = .systemBackground
        closeButton.layer.cornerRadius = 12
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        sheetView.addSubview(closeButton)
    }

    private func configureOptionButton(_ button: UIButton, title: String) {
        button.setTitle(title, for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        button.contentHorizontalAlignment = .center
        button.translatesAutoresizingMaskIntoConstraints = false
        optionsContainer.addSubview(button)
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            dimView.topAnchor.constraint(equalTo: view.topAnchor),
            dimView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dimView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        sheetBottomConstraint = sheetView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 500)
        sheetBottomConstraint?.isActive = true

        NSLayoutConstraint.activate([
            sheetView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            sheetView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: sheetView.topAnchor, constant: 12),
            titleLabel.centerXAnchor.constraint(equalTo: sheetView.centerXAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 20),

            optionsContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            optionsContainer.leadingAnchor.constraint(equalTo: sheetView.leadingAnchor, constant: 16),
            optionsContainer.trailingAnchor.constraint(equalTo: sheetView.trailingAnchor, constant: -16),
            optionsContainer.heightAnchor.constraint(equalToConstant: 112),

            closeButton.topAnchor.constraint(equalTo: optionsContainer.bottomAnchor, constant: 16),
            closeButton.leadingAnchor.constraint(equalTo: sheetView.leadingAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: sheetView.trailingAnchor, constant: -16),
            closeButton.heightAnchor.constraint(equalToConstant: 56),
            closeButton.bottomAnchor.constraint(equalTo: sheetView.safeAreaLayoutGuide.bottomAnchor, constant: -8)
        ])
    }

    // MARK: - Actions

    @objc private func nameTapped() {
        onSelect?(.name)
        dismissAnimated()
    }

    @objc private func ratingTapped() {
        onSelect?(.rating)
        dismissAnimated()
    }

    @objc private func closeTapped() {
        dismissAnimated()
    }

    // MARK: - Animations

    private func animateIn() {
        view.layoutIfNeeded()
        sheetBottomConstraint?.constant = -16
        UIView.animate(withDuration: 0.25) {
            self.dimView.alpha = 1
            self.view.layoutIfNeeded()
        }
    }

    private func dismissAnimated() {
        sheetBottomConstraint?.constant = 500
        UIView.animate(withDuration: 0.25, animations: {
            self.dimView.alpha = 0
            self.view.layoutIfNeeded()
        }, completion: { _ in
            self.dismiss(animated: false)
        })
    }
}


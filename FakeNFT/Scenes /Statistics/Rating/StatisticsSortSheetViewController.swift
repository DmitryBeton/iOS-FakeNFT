import UIKit

final class StatisticsSortSheetViewController: UIViewController {

    var onSelect: ((StatisticsSortOption) -> Void)?
    var onClose: (() -> Void)?

    private let current: StatisticsSortOption

    private let dimView = UIView()
    private let sheetView = UIView()

    private let titleLabel = UILabel()
    private let optionsContainer = UIView()
    private let nameButton = UIButton(type: .system)
    private let ratingButton = UIButton(type: .system)
    private let closeButton = UIButton(type: .system)

    private var sheetBottomConstraint: NSLayoutConstraint?

    init(current: StatisticsSortOption) {
        self.current = current
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLayout()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateIn()
    }

    private func setupUI() {
        view.backgroundColor = .clear

        // затемнение как на макете
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        dimView.alpha = 0
        dimView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dimView)

        let tap = UITapGestureRecognizer(target: self, action: #selector(closeTapped))
        dimView.addGestureRecognizer(tap)

        // фон самой шторки (сероватый)
        sheetView.backgroundColor = .secondarySystemBackground
        sheetView.layer.cornerRadius = 16
        sheetView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        sheetView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sheetView)

        titleLabel.text = "Сортировка"
        titleLabel.font = .systemFont(ofSize: 13, weight: .medium)
        titleLabel.textColor = .secondaryLabel
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        sheetView.addSubview(titleLabel)

        // блок с вариантами (чуть светлее/другое пятно)
        optionsContainer.backgroundColor = .tertiarySystemBackground
        optionsContainer.layer.cornerRadius = 12
        optionsContainer.translatesAutoresizingMaskIntoConstraints = false
        sheetView.addSubview(optionsContainer)

        configureOptionButton(nameButton, title: StatisticsSortOption.name.title)
        configureOptionButton(ratingButton, title: StatisticsSortOption.rating.title)

        nameButton.addTarget(self, action: #selector(nameTapped), for: .touchUpInside)
        ratingButton.addTarget(self, action: #selector(ratingTapped), for: .touchUpInside)

        // кнопка закрыть отдельной белой “плиткой”
        closeButton.setTitle("Закрыть", for: .normal)
        closeButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        closeButton.setTitleColor(.systemBlue, for: .normal)
        closeButton.backgroundColor = .systemBackground
        closeButton.layer.cornerRadius = 12
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        sheetView.addSubview(closeButton)
    }

    private func configureOptionButton(_ button: UIButton, title: String) {
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        button.setTitleColor(.systemBlue, for: .normal)
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

        sheetBottomConstraint = sheetView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 400)
        sheetBottomConstraint?.isActive = true

        NSLayoutConstraint.activate([
            sheetView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sheetView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: sheetView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: sheetView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: sheetView.trailingAnchor, constant: -16)
        ])

        NSLayoutConstraint.activate([
            optionsContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            optionsContainer.leadingAnchor.constraint(equalTo: sheetView.leadingAnchor, constant: 16),
            optionsContainer.trailingAnchor.constraint(equalTo: sheetView.trailingAnchor, constant: -16),
            optionsContainer.heightAnchor.constraint(equalToConstant: 112)
        ])

        NSLayoutConstraint.activate([
            nameButton.topAnchor.constraint(equalTo: optionsContainer.topAnchor),
            nameButton.leadingAnchor.constraint(equalTo: optionsContainer.leadingAnchor),
            nameButton.trailingAnchor.constraint(equalTo: optionsContainer.trailingAnchor),
            nameButton.heightAnchor.constraint(equalToConstant: 56)
        ])

        let separator = UIView()
        separator.backgroundColor = .separator
        separator.translatesAutoresizingMaskIntoConstraints = false
        optionsContainer.addSubview(separator)

        NSLayoutConstraint.activate([
            separator.leadingAnchor.constraint(equalTo: optionsContainer.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: optionsContainer.trailingAnchor),
            separator.topAnchor.constraint(equalTo: nameButton.bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 0.5)
        ])

        NSLayoutConstraint.activate([
            ratingButton.topAnchor.constraint(equalTo: separator.bottomAnchor),
            ratingButton.leadingAnchor.constraint(equalTo: optionsContainer.leadingAnchor),
            ratingButton.trailingAnchor.constraint(equalTo: optionsContainer.trailingAnchor),
            ratingButton.heightAnchor.constraint(equalToConstant: 56)
        ])

        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: optionsContainer.bottomAnchor, constant: 8),
            closeButton.leadingAnchor.constraint(equalTo: sheetView.leadingAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: sheetView.trailingAnchor, constant: -16),
            closeButton.heightAnchor.constraint(equalToConstant: 56),
            closeButton.bottomAnchor.constraint(equalTo: sheetView.safeAreaLayoutGuide.bottomAnchor, constant: -8)
        ])
    }

    @objc private func nameTapped() {
        onSelect?(.name)
        dismissAnimated()
    }

    @objc private func ratingTapped() {
        onSelect?(.rating)
        dismissAnimated()
    }

    @objc private func closeTapped() {
        onClose?()
        dismissAnimated()
    }

    private func animateIn() {
        view.layoutIfNeeded()
        sheetBottomConstraint?.constant = 0
        UIView.animate(withDuration: 0.25) {
            self.dimView.alpha = 1
            self.view.layoutIfNeeded()
        }
    }

    private func dismissAnimated() {
        sheetBottomConstraint?.constant = 400
        UIView.animate(withDuration: 0.25, animations: {
            self.dimView.alpha = 0
            self.view.layoutIfNeeded()
        }, completion: { _ in
            self.dismiss(animated: false)
        })
    }
}


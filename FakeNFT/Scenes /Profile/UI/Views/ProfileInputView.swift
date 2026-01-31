import UIKit

final class ProfileInputView: UIStackView {
    
    // MARK: - Public Types
    
    enum InputFieldType {
        case textField
        case textView
    }
    
    // MARK: - Bindings
    
    var onTextChange: ((String) -> Void)?
    
    // MARK: - Public Properties
    
    var title: String = "" {
        didSet {
            titleLabel.text = title
        }
    }
    
    var inputText: String = "" {
        didSet {
            switch inputType {
            case .textField:
                inputTextField.text = inputText
            case .textView:
                inputTextView.text = inputText
            }
        }
    }
    
    // MARK: - Views
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .headline3
        label.textColor = UIColor(resource: .nftBlack)
        return label
    }()
    
    private lazy var inputTextView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = UIColor(resource: .nftLightGray)
        textView.textColor = UIColor(resource: .nftBlack)
        textView.isScrollEnabled = true
        textView.font = .bodyRegular
        textView.textContainerInset = UIEdgeInsets(
            top: 11,
            left: 16,
            bottom: 11,
            right: 16
        )
        textView.layer.masksToBounds = true
        textView.layer.cornerRadius = 12
        textView.delegate = self
        return textView
    }()
    
    private lazy var inputTextField: UITextField = {
        let textField = UITextField()
        textField.textColor = UIColor(resource: .nftBlack)
        textField.font = .bodyRegular
        textField.returnKeyType = .done
        return textField
    }()
    
    private lazy var inputTextFieldContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(resource: .nftLightGray)
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 12
        view.layoutMargins = UIEdgeInsets(
            top: 11,
            left: 16,
            bottom: 11,
            right: 16
        )
        view.addSubview(inputTextField)
        return view
    }()
    
    // MARK: - Private Properties
    
    private let inputType: InputFieldType
    
    // MARK: - Init
    
    init(inputType: InputFieldType) {
        self.inputType = inputType
        super.init(frame: .zero)
        setupViews()
        setupConstraints()
        setupActions()
    }
    
    required init(coder: NSCoder) {
        assertionFailure("init(coder:) has not been implemented")
        self.inputType = .textField
        super.init(coder: coder)
    }
    
    // MARK: - UI Methods
    
    private func setupViews() {
        axis = .vertical
        spacing = 8
        alignment = .fill
        distribution = .fill
        
        addArrangedSubview(titleLabel)
        
        switch inputType {
        case .textField:
            addArrangedSubview(inputTextFieldContainer)
        case .textView:
            addArrangedSubview(inputTextView)
        }
    }
    
    private func setupConstraints() {
        switch inputType {
        case .textField:
            [inputTextField].disableAutoresizingMasks()
            
            NSLayoutConstraint.activate([
                inputTextFieldContainer.heightAnchor.constraint(equalToConstant: 44),
                
                inputTextField.topAnchor.constraint(equalTo: inputTextFieldContainer.layoutMarginsGuide.topAnchor),
                inputTextField.leadingAnchor.constraint(equalTo: inputTextFieldContainer.layoutMarginsGuide.leadingAnchor),
                inputTextField.trailingAnchor.constraint(equalTo: inputTextFieldContainer.layoutMarginsGuide.trailingAnchor),
                inputTextField.bottomAnchor.constraint(equalTo: inputTextFieldContainer.layoutMarginsGuide.bottomAnchor)
            ])
            
        case .textView:
            inputTextView.heightAnchor.constraint(equalToConstant: 132).isActive = true
        }
    }
    
    private func setupActions() {
        switch inputType {
        case .textField:
            inputTextField.addTarget(
                self,
                action: #selector(inputTextFieldChanged),
                for: .editingChanged
            )
            inputTextField.addTarget(
                self,
                action: #selector(donePressed),
                for: .editingDidEndOnExit
            )
            
        case .textView: break
        }
    }
    
    // MARK: - Actions
    
    @objc private func inputTextFieldChanged() {
        onTextChange?(inputTextField.text ?? "")
    }
    
    @objc private func donePressed() {
        inputTextField.resignFirstResponder()
    }
}

// MARK: - TextFieldDelegate

extension ProfileInputView: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        onTextChange?(inputTextView.text)
    }
    
}

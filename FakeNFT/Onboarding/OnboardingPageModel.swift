import UIKit

struct OnboardingPageModel {
    let image: UIImage
    let title: String
    let text: String
    let showCloseButton: Bool
    let showActionButton: Bool
    
    static func pages() -> [OnboardingPageModel] {
        return [
            OnboardingPageModel(
                image: UIImage(resource: .onboardingOne),
                title: "Исследуйте",
                text: "Присоединяйтесь и откройте новый мир уникальных NFT для коллекционеров",
                showCloseButton: true,
                showActionButton: false
            ),
            OnboardingPageModel(
                image: UIImage(resource: .onboardingTwo),
                title: "Коллекционируйте",
                text: "Пополняйте свою коллекцию эксклюзивными картинками, созданными нейросетью!",
                showCloseButton: true,
                showActionButton: false
            ),
            OnboardingPageModel(
                image: UIImage(resource: .onboardingThree),
                title: "Состязайтесь",
                text: "Смотрите статистику других и покажите всем, что у вас самая ценная коллекция",
                showCloseButton: false,
                showActionButton: true
            )
        ]
    }
}

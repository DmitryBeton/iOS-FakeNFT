import Foundation

enum CartViewState {
    case idle
    case loading
    case loadingPlaceholders(items: [UICartItem])
    case loaded(items: [UICartItem], total: Double)
    case empty
    case error(error: AppError)
}

/// Контракт ViewModel экрана корзины (MVVM).
///
/// Отвечает за:
/// - загрузку/мутации корзины;
/// - сортировку и локальный поиск;
/// - публикацию состояния экрана для View.
///
/// Потоки:
/// - `onStateChange` должен обрабатываться View на main thread.
protocol CartViewModelProtocol: AnyObject {
    /// Активная сортировка данных корзины.
    var sortOption: SortOption { get set }
    /// Текущее состояние экрана.
    var state: CartViewState { get }
    /// Callback изменения состояния.
    var onStateChange: ((CartViewState) -> Void)? { get set }
    /// Количество отображаемых элементов (с учетом поиска/сортировки).
    var itemsCount: Int { get }
    /// Полное количество элементов корзины (без учета фильтра поиска).
    var totalItemsCount: Int { get }
    /// Суммарная стоимость всех элементов корзины.
    var totalPrice: Double { get }

    /// Загружает корзину и публикует состояние (`loading -> ...`).
    func loadItems()
    /// Удаляет элемент из корзины по индексу текущего отображаемого списка.
    func deleteItem(at index: Int)
    /// Добавляет элемент в корзину по `id`.
    func addItem(id: String)
    /// Сортирует данные корзины согласно `sortOption`.
    func sortItems()
    /// Возвращает UI-модель элемента по индексу, если индекс валиден.
    func getUICartItem(at index: Int) -> UICartItem?
    /// Проверяет, пуст ли текущий отображаемый список.
    func isEmpty() -> Bool
    /// Обновляет строку локального поиска и переэмитит состояние.
    func updateSearchQuery(_ query: String)
}

import UIKit

extension PaymentViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.itemsCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: UICurrencyCollectionViewCell = collection.dequeueReusableCell(indexPath: indexPath)

        if let uiCurrency = viewModel.getUICurrency(at: indexPath.row) {
            cell.configure(currency: uiCurrency)
        }

        return cell
    }
}

extension PaymentViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let padding = PaymentViewConstants.Layout.collectionHorizontalPadding
        let spacing = PaymentViewConstants.Layout.minimumInteritemSpacing
        let itemsPerRow = PaymentViewConstants.Layout.itemsPerRow

        let availableWidth = collectionView.frame.width - padding * 2 - spacing * (itemsPerRow - 1)
        let widthPerItem = availableWidth / itemsPerRow
        let height = widthPerItem * PaymentViewConstants.Layout.itemHeightToWidthRatio

        return CGSize(width: widthPerItem, height: height)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        PaymentViewConstants.Layout.sectionInset
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        PaymentViewConstants.Layout.minimumLineSpacing
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        PaymentViewConstants.Layout.minimumInteritemSpacing
    }
}

extension PaymentViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        Self.logger.debug("[\(LogTimestamp.current(), privacy: .public)] Currency selected at index=\(indexPath.row)")
        viewModel.selectCurrency(at: indexPath.row)
        if let currency = viewModel.getUICurrency(at: indexPath.row) {
            selectedCurrencyID = currency.id
            AnalyticsService.shared.track(.currencySelected(id: currency.id, name: currency.name))
        }
        paymentFooterView.isPayEnabled = true
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        Self.logger.debug("[\(LogTimestamp.current(), privacy: .public)] Currency deselected at index=\(indexPath.row)")
        viewModel.clearSelectedCurrency()
        let hasSelection = !(collectionView.indexPathsForSelectedItems?.isEmpty ?? true)
        if hasSelection, let selectedIndex = collectionView.indexPathsForSelectedItems?.first?.row {
            viewModel.selectCurrency(at: selectedIndex)
            selectedCurrencyID = viewModel.getUICurrency(at: selectedIndex)?.id
        }
        if !hasSelection { selectedCurrencyID = nil }
        paymentFooterView.isPayEnabled = hasSelection
    }
}

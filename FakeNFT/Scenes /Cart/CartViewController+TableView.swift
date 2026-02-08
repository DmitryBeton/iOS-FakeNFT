//
//  CartViewController+TableView.swift
//  FakeNFT
//
//  Created by Дмитрий Чалов on 24.01.2026.
//

import UIKit

extension CartViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.itemsCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CartItemViewCell = tableView.dequeueReusableCell()

        guard let cartItem = viewModel.getUICartItem(at: indexPath.row) else {
            return cell
        }

        cell.configure(data: cartItem)
        if !cartItem.isPlaceholder {
            configCell(for: cell, with: cartItem)
        }
        Self.logger.debug("Configured cell for row=\(indexPath.row), id=\(cartItem.id)")

        if cartItem.isPlaceholder {
            cell.onDeleteButtonTapped = nil
        } else {
            cell.onDeleteButtonTapped = { [weak self, weak cell] in
                guard let self, let cell, let actualIndexPath = self.tableView.indexPath(for: cell) else { return }
                Self.logger.info("Delete button tapped for row=\(actualIndexPath.row), id=\(cartItem.id)")
                self.presentDeleteAlert(for: cartItem, at: actualIndexPath, image: cell.currentImage)
            }
        }

        return cell
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        Self.logger.debug("Configuring trailing swipe actions for row=\(indexPath.row)")

        let deleteAction = UIContextualAction(
            style: .destructive,
            title: Localization.Cart.deleteButton.localized
        ) { [weak self] _, _, completion in
            guard let self else {
                completion(false)
                return
            }

            Self.logger.info("Swipe-to-delete initiated for row=\(indexPath.row)")
            self.viewModel.deleteItem(at: indexPath.row)
            Self.logger.debug("Requested deletion for cart item at row=\(indexPath.row)")
            completion(true)
        }

        deleteAction.backgroundColor = UIColor(resource: .nftRed)
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

    func configCell(for cell: CartItemViewCell, with photo: UICartItem) {
        if let url = photo.imageURL {
            cell.setCellImage(with: url)
        }
    }
}

private extension CartViewController {
    func presentDeleteAlert(for item: UICartItem, at indexPath: IndexPath, image: UIImage?) {
        let alertVC = DeleteConfirmationAlertViewController(image: image)
        alertVC.onDeleteTapped = { [weak self] in
            self?.viewModel.deleteItem(at: indexPath.row)
        }
        alertVC.onCancelTapped = {}
        alertVC.show(on: self)
    }
}

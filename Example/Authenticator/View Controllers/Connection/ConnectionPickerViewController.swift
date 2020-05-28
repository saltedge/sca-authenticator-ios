//
//  ConnectionPickerViewController
//  This file is part of the Salt Edge Authenticator distribution
//  (https://github.com/saltedge/sca-authenticator-ios)
//  Copyright © 2020 Salt Edge Inc.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, version 3 or later.
//
//  This program is distributed in the hope that it will be useful, but
//  WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
//  General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program. If not, see <http://www.gnu.org/licenses/>.
//
//  For the additional permissions granted for Salt Edge Authenticator
//  under Section 7 of the GNU General Public License see THIRD_PARTY_NOTICES.md
//

import UIKit

private struct Layout {
    static let cellHeight: CGFloat = 96.0
}

final class ConnectionPickerViewController: BaseViewController {
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = .backgroundColor
        tableView.separatorStyle = .none
        tableView.register(ConnectionCell.self)
        return tableView
    }()
    private let proceedButton: CustomButton = {
        let button = CustomButton(text: l10n(.proceed))
        button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        button.isEnabled = false
        button.alpha = 0.5
        return button
    }()
    private var viewModel: ConnectionPickerViewModel

    private var selectedIndex: Int? {
        didSet {
            proceedButton.isEnabled = true
            proceedButton.alpha = 1.0
        }
    }

    init(viewModel: ConnectionPickerViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: .authenticator_main)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        title = l10n(.chooseConnection)
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancel)
        )
        layout()
    }

    @objc private func buttonPressed() {
        guard let selectedIndex = selectedIndex else { return }

        viewModel.selectedConnection(at: IndexPath(row: selectedIndex, section: 0))
    }

    @objc private func cancel() {
        close()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UITableViewDataSource
extension ConnectionPickerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ConnectionCell = tableView.dequeueReusableCell(for: indexPath)
        cell.viewModel = viewModel.cellViewModel(at: indexPath)
        cell.selectionStyle = .none
        cell.picked = indexPath.row == selectedIndex
        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Layout.cellHeight
    }
}

// MARK: - UITableViewDelegate
extension ConnectionPickerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? ConnectionCell else { return }

        tableView.deselectRow(at: indexPath, animated: true)

        if indexPath.row != selectedIndex {
            selectedIndex = indexPath.row
            cell.picked = true
        }
        tableView.reloadData()
    }
}

extension ConnectionPickerViewController: Layoutable {
    func layout() {
        view.addSubviews(tableView, proceedButton)

        tableView.topToSuperview()
        tableView.widthToSuperview()
        tableView.bottomToTop(of: proceedButton, offset: -5.0)

        proceedButton.centerXToSuperview()
        proceedButton.bottomToSuperview(offset: -20.0)
        proceedButton.widthToSuperview(offset: -64.0)
    }
}

//
//  ConnectionsViewController.swift
//  This file is part of the Salt Edge Authenticator distribution
//  (https://github.com/saltedge/sca-authenticator-ios)
//  Copyright © 2019 Salt Edge Inc.
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
    static let noDataViewTopOffset: CGFloat = AppLayout.screenHeight * 0.11
}

final class ConnectionsViewController: UITableViewController {
    private var noDataView: NoDataView!
    private var viewModel: ConnectionsViewModel

    var connectViewCoordinator: ConnectViewCoordinator?

    init(viewModel: ConnectionsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: .authenticator_main)
        setupNoDataView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
        viewModel.refreshConsents()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundColor
        extendedLayoutIncludesOpaqueBars = true
        navigationItem.title = l10n(.connections)
        setupTableView()
        setupRefreshControl()
        layout()
        updateViewsHiddenState()
        setupObservers()
    }

    @objc private func reloadData() {
        tableView.reloadData()
    }

    func updateViewsHiddenState() {
        tableView.reloadData()
        UIView.animate(
            withDuration: 0.3,
            animations: {
                self.noDataView.alpha = self.viewModel.hasDataToShow ? 0.0 : 1.0
            }
        )
    }

    deinit {
        NotificationsHelper.removeObserver(self)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup
private extension ConnectionsViewController {
    func setupObservers() {
        NotificationsHelper.observe(
            self,
            selector: #selector(reloadData),
            name: NSLocale.currentLocaleDidChangeNotification,
            object: nil
        )
        NotificationsHelper.observe(
            self,
            selector: #selector(reloadData),
            name: .locationServicesStatusDidChange,
            object: nil
        )
    }
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.sectionHeaderHeight = 0.0
        tableView.sectionFooterHeight = 0.0
        tableView.backgroundColor = .backgroundColor
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.register(ConnectionCell.self)
        tableView.separatorStyle = .none
    }

    func setupNoDataView() {
        noDataView = NoDataView(data: viewModel.emptyViewData, action: viewModel.addPressed)
        noDataView.alpha = viewModel.hasDataToShow ? 0 : 1
    }

    func setupRefreshControl() {
        tableView.refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
}

// MARK: UITableViewDataSource
extension ConnectionsViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Layout.cellHeight
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ConnectionCell = tableView.dequeueReusableCell(for: indexPath)

        let cellViewModel = viewModel.cellViewModel(at: indexPath)
        cellViewModel.delegate = self
        cell.viewModel = cellViewModel

        return cell
    }
}

// MARK: UITableViewDelegate
extension ConnectionsViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard #available(iOS 13, *) else {
            self.present(viewModel.actionSheet(for: indexPath), animated: true)
            return
        }
    }
}

// MARK: UISwipeActionsConfiguration
extension ConnectionsViewController {
    override func tableView(_ tableView: UITableView,
                            trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return viewModel.rightSwipeActionsConfiguration(for: indexPath)
    }

    override func tableView(_ tableView: UITableView,
                            leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return viewModel.leftSwipeActionsConfiguration(for: indexPath)
    }
}

// MARK: - Actions
private extension ConnectionsViewController {
    func showActionSheet(at indexPath: IndexPath) {}

    @objc func refresh() {
        viewModel.refreshConsents(
            completion: {
                DispatchQueue.main.async {
                    self.refreshControl?.endRefreshing()
                }
            }
        )
    }
}

// MARK: - Layout
extension ConnectionsViewController: Layoutable {
    func layout() {
        tableView.addSubview(noDataView)

        noDataView.topToSuperview(view.safeAreaLayoutGuide.topAnchor, offset: Layout.noDataViewTopOffset)
        noDataView.widthToSuperview()
    }
}

// MARK: - ConnectionCellEventsDelegate
extension ConnectionsViewController: ConnectionCellEventsDelegate {
    func renamePressed(id: String) {
        viewModel.updateName(by: id)
    }

    func accessLocationPressed() {
        if LocationManager.shared.notDeterminedAuthorization {
            LocationManager.shared.requestLocationAuthorization()
        } else {
            showConfirmationAlert(
                withTitle: l10n(.accessToLocationServices),
                message: l10n(.turnOnLocationSharingDescription),
                confirmActionTitle: l10n(.goToSettings),
                confirmActionStyle: .default,
                confirmAction: { _ in
                    guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }

                    if UIApplication.shared.canOpenURL(settingsUrl) {
                        UIApplication.shared.open(settingsUrl)
                    }
                }
            )
        }
    }

    func supportPressed(email: String) {
        viewModel.showSupport(email: email)
    }

    func deletePressed(id: String, showConfirmation: Bool) {
        checkInternetAndRemoveConnection(id: id, showConfirmation: showConfirmation)
    }

    func reconnectPreseed(id: String) {
        viewModel.reconnect(id: id)
    }

    func consentsPressed(id: String) {
        viewModel.consentsPressed(connectionId: id)
    }
    
    private func checkInternetAndRemoveConnection(id: String, showConfirmation: Bool) {
        guard ReachabilityManager.shared.isReachable else {
            self.showConfirmationAlert(
                withTitle: l10n(.noInternetConnection),
                message: l10n(.pleaseCheckAndTryAgain),
                confirmActionTitle: l10n(.retry),
                confirmAction: { _ in
                    if ReachabilityManager.shared.isReachable { self.viewModel.remove(by: id) }
                }
            )
            return
        }
        
        if showConfirmation {
            showConfirmationAlert(
                withTitle: l10n(.deleteConnection),
                message: l10n(.deleteConnectionDescription),
                confirmActionTitle: l10n(.delete),
                confirmActionStyle: .destructive,
                cancelTitle: l10n(.cancel),
                confirmAction: { _ in
                    self.viewModel.remove(by: id)
                }
            )
        } else {
            viewModel.remove(by: id)
        }
    }
}

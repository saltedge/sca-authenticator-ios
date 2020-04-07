//
//  EditConnectionViewModelSpec
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

import Quick
import Nimble

class EditConnectionViewModelSpec: BaseSpec {
    override func spec() {
        var connection: Connection!
        var viewModel: EditConnectionViewModel!

        beforeEach {
            connection = Connection()
            connection.id = "first"
            connection.name = "First"
            ConnectionRepository.save(connection)

            viewModel = EditConnectionViewModel(connectionId: connection.id)
        }

        afterEach {
            ConnectionRepository.deleteAllConnections()
        }

        describe("init(connectionId)") {
            it("should initialize view model") {
                expect(viewModel.state.value).to(equal(EditConnectionViewState.edit(defaultName: "First")))
            }
        }

        describe("updateName") {
            context("when name already exists") {
                it("should change viewModel state to alert") {
                    viewModel.updateName(with: "First")

                    expect(viewModel.state.value).to(equal(EditConnectionViewState.alert(text: "This name already exists.")))
                }
            }

            context("when there is new name") {
                it("should change viewModel state to finish") {
                    viewModel.updateName(with: "New name")

                    expect(connection.name).to(equal("New name"))
                    expect(viewModel.state.value).to(equal(EditConnectionViewState.finish))
                }
            }
        }

        describe("when user did dismiss alert") {
            it("should change viewModel state to edit") {
                viewModel.didDismissAlert()

                expect(viewModel.state.value).to(equal(EditConnectionViewState.edit(defaultName: nil)))
            }
        }
    }
}

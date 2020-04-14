//
//  OnboardingViewModelSpec
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
import UIKit

extension OnboardingCellViewModel: Equatable {
    static func == (lhs: OnboardingCellViewModel, rhs: OnboardingCellViewModel) -> Bool {
        return lhs.image == rhs.image && lhs.title == rhs.title && lhs.description == rhs.description
    }
}

final class OnboardingViewModelSpec: BaseSpec {
    override func spec() {
        let viewModel = OnboardingViewModel()

        beforeEach {
            viewModel.state.value = .normal
            viewModel.resetCurrentPage()
        }

        describe("features") {
            it("should return correct array of onboarding features") {
                // TODO: Replace with correct images when available
                let images = [
                    UIImage(named: "absoluteControl", in: .authenticator_main, compatibleWith: nil)!,
                    UIImage(named: "oneApp", in: .authenticator_main, compatibleWith: nil)!,
                    UIImage(named: "paymentsSecurity", in: .authenticator_main, compatibleWith: nil)!
                ]
                let titles = [l10n(.firstFeature), l10n(.secondFeature), l10n(.thirdFeature)]
                let descriptions = [
                    l10n(.firstFeatureDescription),
                    l10n(.secondFeatureDescription),
                    l10n(.thirdFeatureDescription)
                ]

                let expectedFeatures: [OnboardingCellViewModel] = images.enumerated().map { index, image in
                    return OnboardingCellViewModel(image: image, title: titles[index], description: descriptions[index])
                }

                expect(expectedFeatures).to(equal(viewModel.features))
            }
        }

        describe("numberOfPages") {
            it("should return 3") {
                expect(viewModel.numberOfPages).to(equal(3))
            }
        }

        describe("numberOfSections") {
            it("should return 1") {
                expect(viewModel.numberOfSections).to(equal(1))
            }
        }

        describe("item(at indexPath)") {
            it("should return correct Onboarding feature at given IndexPath") {
                let firstItem = OnboardingCellViewModel(
                    image: UIImage(named: "absoluteControl", in: .authenticator_main, compatibleWith: nil)!,
                    title: l10n(.firstFeature),
                    description: l10n(.firstFeatureDescription)
                )
                let secondItem = OnboardingCellViewModel(
                    image: UIImage(named: "oneApp", in: .authenticator_main, compatibleWith: nil)!,
                    title: l10n(.secondFeature),
                    description: l10n(.secondFeatureDescription)
                )
                let thirdItem = OnboardingCellViewModel(
                    image: UIImage(named: "paymentsSecurity", in: .authenticator_main, compatibleWith: nil)!,
                    title: l10n(.thirdFeature),
                    description: l10n(.thirdFeatureDescription)
                )
                expect(viewModel.item(at: IndexPath(row: 0, section: 0))).to(equal(firstItem))
                expect(viewModel.item(at: IndexPath(row: 1, section: 0))).to(equal(secondItem))
                expect(viewModel.item(at: IndexPath(row: 2, section: 0))).to(equal(thirdItem))
            }
        }

        describe("didPressedNext") {
            context("when state was not reseted to .normal") {
                it("should set state to .showPage(1)") {
                    expect(viewModel.state.value).to(equal(OnboardingViewState.normal))

                    viewModel.didPressedNext()

                    expect(viewModel.state.value).to(equal(OnboardingViewState.showPage(1)))

                    viewModel.didPressedNext()

                    expect(viewModel.state.value).to(equal(OnboardingViewState.showPage(1)))
                }
            }

            context("when state is resetting to .normal after each call") {
                it("should increase page and set .finish when last item appeared") {
                    expect(viewModel.state.value).to(equal(OnboardingViewState.normal))

                    viewModel.didPressedNext()

                    expect(viewModel.state.value).to(equal(OnboardingViewState.showPage(1)))

                    viewModel.didChangePage()
                    viewModel.didPressedNext()

                    expect(viewModel.state.value).to(equal(OnboardingViewState.finish))
                }
            }
        }

        describe("didPressedNext") {
            it("should reset viewModel state to .normal") {
                viewModel.state.value = .showPage(1)

                expect(viewModel.state.value).to(equal(OnboardingViewState.showPage(1)))

                viewModel.didChangePage()

                expect(viewModel.state.value).to(equal(OnboardingViewState.normal))
            }
        }

        describe("countLastPage") {
            it("should handle swipe events and catch last page") {
                viewModel.countLastPage(collectionViewWidth: 7, scrollViewContentXOffest: 0.5)

                expect(viewModel.state.value).to(equal(OnboardingViewState.swipedAt(0)))

                viewModel.didChangePage()

                viewModel.countLastPage(collectionViewWidth: 65, scrollViewContentXOffest: 70)

                expect(viewModel.state.value).to(equal(OnboardingViewState.swipedAt(1)))

                viewModel.didChangePage()

                viewModel.countLastPage(collectionViewWidth: 65, scrollViewContentXOffest: 140)

                expect(viewModel.state.value).to(equal(OnboardingViewState.finish))
            }
        }

        describe("Styles") {
            context("backgroundColor") {
                it("should return correct color with given name") {
                    expect(viewModel.backgroundColor).to(equal(UIColor.backgroundColor))
                }
            }

            context("indicatorColor") {
                it("should return correct color with given name") {
                    expect(viewModel.indicatorColor).to(equal(UIColor.lightBlue))
                }
            }

            context("pageIndicatorTintColor") {
                it("should return correct color with given name") {
                    expect(viewModel.pageIndicatorTintColor).to(equal(UIColor.lightGray))
                }
            }

            context("titleColor") {
                it("should return correct color with given name") {
                    expect(viewModel.titleColor).to(equal(UIColor.lightBlue))
                }
            }

            context("buttonFont") {
                it("should return correct font with given name") {
                    expect(viewModel.buttonFont).to(equal(UIFont.systemFont(ofSize: 18.0, weight: .medium)))
                }
            }
        }
    }
}

//
//  CatalogPresenter.swift
//  FakeNFT
//
//  Created by Илья Лощилов on 15.10.2024.
//

import Foundation

enum CatalogPresenterState {
    case initial, loading, failed(Error), data([NftCollection])
}

protocol CatalogPresenter: AnyObject {
    func viewDidLoad()
    func setView(_ view: CatalogView)
}

final class CatalogPresenterImpl {
    
    //MARK: - Private properties
    
    weak var view: CatalogView?
    private let services: ServicesAssembly
    private var state = CatalogPresenterState.initial {
        didSet {
            stateDidChanged()
        }
    }
    
    //MARK: - Initializers
    
    init(servicesAssembly: ServicesAssembly) {
        self.services = servicesAssembly
    }
    
    // MARK: - Private Methods
    
    private func stateDidChanged() {
        switch state {
        case .initial:
            assertionFailure("can't move to initial state")
        case .loading:
            view?.showLoading()
            loadCollections()
        case .data(let collection):
            view?.hideLoading()
            let cellModels = collection.map {
                CatalogCellModel(title: $0.name,
                                 size: $0.nfts.count,
                                 cover: $0.cover)
            }
            view?.displayCells(cellModels)
        case .failed(let error):
            let errorModel = makeErrorModel(error)
            view?.hideLoading()
            view?.showError(errorModel)
        }
    }
    
    private func loadCollections() {
        services.nftCollectionService.loadNftCollections() { [weak self] result in
            switch result {
            case .success(let collections):
                self?.state = .data(collections)
            case .failure(let error):
                self?.state = .failed(error)
            }
        }
    }
    
    private func makeErrorModel(_ error: Error) -> ErrorModel {
        let message: String
        switch error {
        case is NetworkClientError:
            message = NSLocalizedString("Error.network", comment: "")
        default:
            message = NSLocalizedString("Error.unknown", comment: "")
        }

        let actionText = NSLocalizedString("Error.repeat", comment: "")
        return ErrorModel(message: message, actionText: actionText) { [weak self] in
            self?.state = .loading
        }
    }
}

extension CatalogPresenterImpl: CatalogPresenter {
    func setView(_ view: any CatalogView) {
        self.view = view
    }

    func viewDidLoad() {
        self.state = .loading
    }
}

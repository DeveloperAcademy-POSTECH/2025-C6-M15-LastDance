//
//  IdentitySelectionViewModel.swift
//  LastDance
//
//  Created by donghee on 10/13/25.
//

import Moya
import SwiftUI

@MainActor
final class IdentitySelectionViewModel: ObservableObject {
    @Published var selectedType: UserType?

    private let dataManager = SwiftDataManager.shared
    private let visitorService = VisitorAPIService()
    private let venueService = VenueAPIService()

    /// 사용자 타입 선택
    func selectUserType(_ type: UserType) {
        selectedType = type
    }

    /// 선택 확정 및 저장
    func confirmSelection() {
        guard let selectedType = selectedType else {
            // TODO: 선택하지 않은 경우 예외 처리
            return
        }

        saveUserType(selectedType)
        
        if selectedType == .viewer {
            createVisitorAPI()
        }
    }
    
    /// 사용자 타입 저장
    private func saveUserType(_ type: UserType) {
        UserDefaults.standard.set(type.rawValue, forKey: UserDefaultsKey.userType.key)
        Log.info("User type saved: \(type.rawValue)")
    }
    
    /// visitor생성 API 호출
    private func createVisitorAPI(name: String? = nil) {

        let uuid = loadOrCreateVisitorUUID()
        
        let request = VisitorCreateRequestDto(uuid: uuid, name: name)
        
        visitorService.createVisitor(request: request) { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let dto):
                    UserDefaults.standard.set(
                        dto.uuid,
                        forKey: UserDefaultsKey.visitorUUID.rawValue)
                    Log.debug("Visitor created. id=\(dto.id), uuid=\(dto.uuid)")
                    
                    let visitor = Visitor(
                        id: dto.id,
                        uuid: dto.uuid,
                        name: dto.name
                    )
                    self.dataManager.insert(visitor)
                case .failure(let error):
                    if let moyaError = error as? MoyaError,
                       let data = moyaError.response?.data,
                       let err = try? JSONDecoder().decode(ErrorResponseDto.self, from: data) {
                        let messages = err.detail.map { $0.msg }.joined(separator: ", ")
                        Log.warning("Visitor create validation error: \(messages)")
                    }
                    Log.error("Visitor create failed: \(error)")
                }
            }
        }
    }

    /// 저장된 uuid가 있으면 재사용, 없으면 새로 생성해서 저장
    private func loadOrCreateVisitorUUID() -> String {
        if let existing = UserDefaults.standard.string(forKey: UserDefaultsKey.visitorUUID.rawValue) {
            return existing
        }
        let newUUID = UUID().uuidString
        UserDefaults.standard.set(newUUID, forKey: UserDefaultsKey.visitorUUID.rawValue)
        return newUUID
    }
    
    /// 서버에 있는 모든 전시장 정보 로드 (확인용)
    func loadAllVenues(onComplete: (() -> Void)? = nil) {
        venueService.getVenues { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let list):
                    Log.info("success. count=\(list.count)")
                case .failure(let error):
                    if let moyaError = error as? MoyaError,
                       let data = moyaError.response?.data,
                       let err = try? JSONDecoder().decode(ErrorResponseDto.self, from: data) {
                        let messages = err.detail.map { $0.msg }.joined(separator: ", ")
                        Log.warning("validation: \(messages)")
                    } else {
                        Log.error("failed: \(error)")
                    }
                }
            }
        }
    }
}

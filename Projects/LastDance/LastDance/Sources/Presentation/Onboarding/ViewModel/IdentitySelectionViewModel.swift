//
//  IdentitySelectionViewModel.swift
//  LastDance
//
//  Created by donghee, 신얀 on 10/13/25.
//

import Moya
import SwiftUI

@MainActor
final class IdentitySelectionViewModel: ObservableObject {
    @Published var selectedType: UserType?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var artistCodes: [String] = Array(
        repeating: "", count: ArtistCodeConstants.codeLength)
    @Published var showArtistCodeError = false

    private let dataManager = SwiftDataManager.shared
    private let visitorService = VisitorAPIService()
    private let venueService = VenueAPIService()
    private let artistService = ArtistAPIService()

    /// 사용자 타입 선택
    func selectUserType(_ type: UserType) {
        selectedType = type
    }

    /// 작가 인증 여부 확인
    func isArtistAuthenticated() -> Bool {
        return UserDefaults.standard.object(forKey: UserDefaultsKey.artistId.rawValue) != nil
    }

    /// 작가 코드 입력 완료 여부
    var isCodeComplete: Bool {
        artistCodes.contains { !$0.isEmpty }
    }

    /// 선택 확정 및 저장
    func confirmSelection() {
        guard let selectedType = selectedType else {
            // TODO: 선택하지 않은 경우 예외 처리
            return
        }

        saveUserType(selectedType)

        if selectedType == .viewer {
            ensureVisitorExists()
        }
    }

    /// 사용자 타입 저장
    private func saveUserType(_ type: UserType) {
        UserDefaults.standard.set(type.rawValue, forKey: UserDefaultsKey.userType.key)
        Log.info("User type saved: \(type.rawValue)")
    }

    /// AppClip/이전 실행에서 만든 visitor가 있는지 판단
    private func ensureVisitorExists() {
        if let existingId = UserDefaults.standard.object(forKey: UserDefaultsKey.visitorId.rawValue)
            as? Int
        {
            Log.debug("existing visitorId found: \(existingId), skip createVisitorAPI()")
            return
        }

        createVisitorAPI()
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
                        dto.id,
                        forKey: UserDefaultsKey.visitorId.rawValue)
                    UserDefaults.standard.set(
                        dto.uuid,
                        forKey: UserDefaultsKey.visitorUUID.rawValue
                    )
                    Log.debug("Visitor created. id=\(dto.id), uuid=\(dto.uuid)")

                    let visitor = Visitor(
                        id: dto.id,
                        uuid: dto.uuid,
                        name: dto.name
                    )
                    self.dataManager.insert(visitor)

                    // visitor 생성 성공 후 디바이스 토큰 전송
                    DeviceTokenManager.shared.registerDeviceTokenIfNeeded()
                case .failure(let error):
                    if let moyaError = error as? MoyaError,
                        let data = moyaError.response?.data,
                        let err = try? JSONDecoder().decode(ErrorResponseDto.self, from: data)
                    {
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
        if let existing = UserDefaults.standard.string(forKey: UserDefaultsKey.visitorUUID.rawValue)
        {
            return existing
        }
        let newUUID = UUID().uuidString
        UserDefaults.standard.set(newUUID, forKey: UserDefaultsKey.visitorUUID.rawValue)
        return newUUID
    }

    /// 작가 코드 인증
    func verifyArtistCode(_ code: String, completion: @escaping (Bool) -> Void) {
        isLoading = true
        errorMessage = nil
        showArtistCodeError = false

        let request = ArtistCodeRequestDto(login_code: code)

        artistService.artistLogin(dto: request) { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                self.isLoading = false

                switch result {
                case .success(let dto):
                    // 작가 정보 저장
                    Log.debug(
                        "Artist login response - id: \(dto.id), uuid: '\(dto.uuid)' (length: \(dto.uuid.count))"
                    )
                    UserDefaults.standard.set(dto.id, forKey: UserDefaultsKey.artistId.rawValue)
                    UserDefaults.standard.set(dto.uuid, forKey: UserDefaultsKey.artistUUID.rawValue)

                    // 저장 직후 확인
                    if let savedUUID = UserDefaults.standard.string(
                        forKey: UserDefaultsKey.artistUUID.rawValue)
                    {
                        Log.debug("Verification: artistUUID saved correctly: '\(savedUUID)'")
                    } else {
                        Log.error("Verification failed: artistUUID not saved!")
                    }

                    UserDefaults.standard.set(dto.name, forKey: UserDefaultsKey.artistName.rawValue)

                    let artistCode = ArtistMapper.toArtistCodeModel(from: dto)
                    self.dataManager.insert(artistCode)

                    // 작가 인증 성공 후 디바이스 토큰 전송
                    DeviceTokenManager.shared.registerDeviceTokenIfNeeded()

                    completion(true)

                case .failure(let error):
                    if let moyaError = error as? MoyaError {
                        // 400대 에러 처리
                        if let statusCode = moyaError.response?.statusCode,
                            (400..<500).contains(statusCode)
                        {
                            self.showArtistCodeError = true
                        }

                        if let data = moyaError.response?.data,
                            let err = try? JSONDecoder().decode(ErrorResponseDto.self, from: data)
                        {
                            let messages = err.detail.map { $0.msg }.joined(separator: ", ")
                            self.errorMessage = messages
                            Log.warning("Artist login validation error: \(messages)")
                        } else {
                            self.errorMessage = "코드 인증에 실패했습니다."
                        }
                    } else {
                        self.errorMessage = "코드 인증에 실패했습니다."
                    }
                    Log.error("Artist login failed: \(error)")
                    completion(false)
                }
            }
        }
    }

    /// 서버에 있는 모든 전시장 정보 로드 (확인용)
    func loadAllVenues(onComplete _: (() -> Void)? = nil) {
        venueService.getVenues { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let list):
                    Log.info("success. count=\(list.count)")
                case .failure(let error):
                    if let moyaError = error as? MoyaError,
                        let data = moyaError.response?.data,
                        let err = try? JSONDecoder().decode(ErrorResponseDto.self, from: data)
                    {
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

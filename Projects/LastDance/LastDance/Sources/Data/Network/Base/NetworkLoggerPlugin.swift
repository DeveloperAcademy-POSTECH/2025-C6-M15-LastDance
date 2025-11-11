//
//  NetworkLoggerPlugin.swift
//  LastDance
//
//  Created by 신얀 on 10/8/25.
//

import Moya

struct NetworkLoggerPlugin: PluginType {

  /// Request 보낼 때 요청하는 함수
  func willSend(_ request: RequestType, target: TargetType) {
    guard let httpRequest = request.request else {
      Log.debug("🚧 [HTTP Request] 유효하지 않은 요청")
      return
    }

    let url = httpRequest.description
    let method = httpRequest.httpMethod ?? "unknown method"

    /// HTTP Request Summary
    var httpLog = """
      =========================================================
      📤 REQUEST
      =========================================================
      [\(method)] \(url)
      Target: \(target)
      """

    /// HTTP Request Header
    httpLog.append("HEADER: [\n")
    httpRequest.allHTTPHeaderFields?.forEach {
      httpLog.append("\t\($0): \($1)\n")
    }
    httpLog.append("]\n")

    /// HTTP Request Body
    if let body = httpRequest.httpBody,
      let bodyString = String(bytes: body, encoding: String.Encoding.utf8)
    {
      httpLog.append("BODY: \n\(bodyString)\n")
    }
    httpLog.append("\n====================HTTP Response End====================")

    Log.debug(httpLog)
  }

  /// Response 받을 때 요청하는 함수
  func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
    switch result {
    case .success(let response):
      onSuceed(response, target: target, isFromError: false)
    case .failure(let error):
      onFail(error, target: target)
    }
  }

  /// 네트워크 통신했을 때 함수
  func onSuceed(_ response: Response, target: TargetType, isFromError: Bool) {
    let request = response.request
    let url = request?.url?.absoluteString ?? "nil"
    let statusCode = response.statusCode
    let statusIcon = (200..<300).contains(statusCode) ? "✅" : "⚠️"

    /// HTTP Response Summary
    var httpLog = """
      =========================================================
      📤 RESPONSE \(statusIcon) \(statusCode)
      =========================================================
      \(url)
      Target: \(target)
      """

    /// HTTP Response Header
    httpLog.append("HEADER: [\n")
    response.response?.allHeaderFields.forEach {
      httpLog.append("\t\($0): \($1)\n")
    }
    httpLog.append("]\n")

    /// HTTP Response Data
    httpLog.append("RESPONSE DATA: \n")
    if let responseString = String(
      bytes: response.data,
      encoding: String.Encoding.utf8
    ) {
      httpLog.append("\(responseString)\n")
    }
    httpLog.append("------------------HTTP Response End------------------")

    Log.debug(httpLog)
  }

  /// 네트워크 실패 시 함수
  func onFail(_ error: MoyaError, target: TargetType) {
    if let response = error.response {
      onSuceed(response, target: target, isFromError: true)
      return
    }

    /// HTTP Error Summary
    var httpLog = """
      =========================================================
      ❌ NETWORK ERROR
      =========================================================
      Target: \(target)
      Error Code: \(error.errorCode)
      """

    httpLog.append(
      "MESSAGE: \(error.failureReason ?? error.errorDescription ?? "알 수 없는 에러")\n"
    )
    httpLog.append("------------------HTTP Response End------------------")

    Log.debug(httpLog)
  }
}

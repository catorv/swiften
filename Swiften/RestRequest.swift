//
// Created by Cator Vee on 7/10/16.
// Copyright (c) 2016 Cator Vee. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireObjectMapper
import ObjectMapper

open class RestRequest {
  
  public typealias Params = [String : AnyObject]
  public typealias Options = [String : Any]
  
  open var loadingIndicator: LoadingIndicator?
  
  fileprivate let tid: Int
  
  open var params: Params
  open var options: Options
  
  open var quiet: RestRequest {
    options["quiet"] = true
    return self
  }
  
  open var request: DataRequest?
  
  open var paramsBuilder: ((_ request: RestRequest, _ params: Params?, _ start: Int?, _ limit: Int?) -> Void)?
  open var requestBuilder: ((_ request: RestRequest) -> DataRequest)?
  
  init(options: Options) {
    self.tid = BaseSession().tick
    self.options = options
    self.params = [:]
  }
  
  /// 设置options
  open func updateOptions(_ options: Options) -> RestRequest {
    for (key, value) in options {
      self.options[key] = value
    }
    return self
  }
  
  /// 设置params
  open func updateParams(_ params: [String:AnyObject]) -> RestRequest {
    for (key, value) in params {
      self.params[key] = value
    }
    return self
  }
  
  /// 取消API请求
  open func cancel() {
    request?.cancel()
  }
  
  /// 调用前准备
  open func prepare(params: Params? = nil, start: Int? = nil, limit: Int? = nil) -> RestRequest {
    if let builder = paramsBuilder {
      builder(self, params, start, limit)
    } else if let params = params {
      return updateParams(params)
    }
    return self
  }
  
  fileprivate func buildRequest() -> DataRequest? {
    if let builder = requestBuilder {
      request = builder(self)
    }
    return request
  }
  
  /// 调用API请求
  open func call<T>(_ method: HTTPMethod, _ callback: @escaping (_ response:RestResponse<T>) -> Void) {
    guard let request = buildRequest() else {
      Log.error("rest[\(self.tid)]: The request is nil.")
      callback(RestResponse<T>(error: .dataError))
      return
    }
    
    Log.info("rest[\(self.tid)]: \(request.debugDescription)")
    
    startLoading()
    
    let dataType: MIMEType = self.options["dataType"] as? MIMEType ?? .json
    
    switch dataType {
    case .json:
      request.responseObject { (response: DataResponse<RestResponse<T>>) in
        self.handleJSON(response: response, callback: callback)
        self.stopLoading()
      }
    default:
      Log.error("rest: unsupported data type (\(dataType))")
      stopLoading()
    }
  }
  
  fileprivate func handleJSON<T>(response: DataResponse<RestResponse<T>>, callback: (_ response: RestResponse<T>) -> Void) {
    Log.info("rest[\(self.tid)]: \(response.response == nil ? "nil" : response.response!.debugDescription) data: \((response.data?.count)!) bytes, \(response.timeline)")
    switch response.result {
    case .success(let value):
      value.rawData = response.data!
      if let httpResponse = response.response {
        value.headers = httpResponse.allHeaderFields
      }
      Log.debug("rest[\(self.tid)]: (Raw String) \(value.rawString == nil ? "nil" : value.rawString!)")
      if !value.isOK {
        Log.error("rest[\(self.tid)]: ResultError[\(value.code)] \(value.errorMessage ?? "")")
      }
      
      callback(value)
    case .failure(let error):
      let value = RestResponse<T>()
      if let httpResponse = response.response {
        let statusCode = httpResponse.statusCode
        if statusCode >= 200 && statusCode < 400 {
          Log.error("rest[\(self.tid)]: \(statusCode) Http Request Error")
          value.error = RestError.httpRequestError(statusCode: statusCode)
          callback(value)
          stopLoading()
          return
        }
      }
      Log.error("rest[\(self.tid)]: \(error)")
      value.error = RestError.dataError
      callback(value)
    }
  }
}

// MARK: - 标准HTTP Method调用

extension RestRequest {
  
  /// 调用GET请求
  func get<T>(_ params: Params? = nil, start: Int? = nil, limit: Int? = nil, callback: @escaping (_ response: RestResponse<T>) -> Void) {
    prepare(params: params, start: start, limit: limit).call(.get, callback)
  }
  
  /// 调用POST请求
  func post<T>(_ params: Params? = nil, start: Int? = nil, limit: Int? = nil, callback: @escaping (_ response: RestResponse<T>) -> Void) {
    prepare(params: params, start: start, limit: limit).call(.post, callback)
  }
  
  /// 调用PUT请求
  func put<T>(_ params: Params? = nil, start: Int? = nil, limit: Int? = nil, callback: @escaping (_ response: RestResponse<T>) -> Void) {
    return prepare(params: params, start: start, limit: limit).call(.put, callback)
  }
  
  /// 调用DELETE请求
  func delete<T>(_ params: Params? = nil, start: Int? = nil, limit: Int? = nil, callback: @escaping (_ response: RestResponse<T>) -> Void) {
    return prepare(params: params, start: start, limit: limit).call(.delete, callback)
  }
  
}

// MARK: - 载入动画

extension RestRequest {
  
  fileprivate func startLoading() {
    guard let loadingIndicator = loadingIndicator else { return }
    if let quiet = options["quiet"] as? Bool, quiet {
      return
    }
    loadingIndicator.startLoading()
  }
  
  fileprivate func stopLoading() {
    guard let loadingIndicator = loadingIndicator else { return }
    if let quiet = options["quiet"] as? Bool, quiet {
      return
    }
    loadingIndicator.startLoading()
  }
  
}

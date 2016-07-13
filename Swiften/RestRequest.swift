//
// Created by Cator Vee on 7/10/16.
// Copyright (c) 2016 Cator Vee. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireObjectMapper
import ObjectMapper

public class RestRequest {

    public typealias Params = [String:AnyObject]
    public typealias Options = [String:Any]

    public var loadingIndicator: LoadingIndicator?

    private let tid: Int

    public var params: Params
    public var options: Options

    public var quiet: RestRequest {
        options["quiet"] = true
        return self
    }

    public var request: Request?

    public var paramsBuilder: ((request: RestRequest, params: Params?, start: Int?, limit: Int?) -> Void)?
    public var requestBuilder: ((request: RestRequest) -> Request)?

    init(options: Options) {
        self.tid = session.tick
        self.options = options
        self.params = [:]
    }

    /// 设置options
    public func updateOptions(options: Options) -> RestRequest {
        for (key, value) in options {
            self.options[key] = value
        }
        return self
    }

    /// 设置params
    public func updateParams(params: [String:AnyObject]) -> RestRequest {
        for (key, value) in params {
            self.params[key] = value
        }
        return self
    }

    /// 取消API请求
    public func cancel() {
        request?.cancel()
    }

    /// 调用前准备
    public func prepare(params params: Params? = nil, start: Int? = nil, limit: Int? = nil) -> RestRequest {
        if let builder = paramsBuilder {
            builder(request: self, params: params, start: start, limit: limit)
        } else {
            if let params = params {
                updateParams(params)
            }
        }
        return self
    }

    private func buildRequest() -> Request? {
        if let builder = requestBuilder {
            request = builder(request: self)
        }
        return request
    }

    /// 调用API请求
    public func call<T>(method: Alamofire.Method, _ callback: (response:RestResponse<T>) -> Void) {
        guard let request = buildRequest() else {
            Log.error("rest[\(self.tid)]: The request is nil.")
            callback(response: RestResponse<T>(error: .dataError))
            return
        }

        Log.info("rest[\(self.tid)]: \(request.debugDescription)")

        startLoading()

        let dataType: MIMEType = self.options["dataType"] as? MIMEType ?? .json

        switch dataType {
        case .json:
            request.responseObject { (response: Alamofire.Response<RestResponse<T>, NSError>) in
                self.handleJSON(response: response, callback: callback)
                self.stopLoading()
            }
        default:
            Log.error("rest: unsupported data type (\(dataType))")
            stopLoading()
        }
    }

    private func handleJSON<T>(response response: Alamofire.Response<RestResponse<T>, NSError>, callback: (response:RestResponse<T>) -> Void) {
        Log.info("rest[\(self.tid)]: \(response.response == nil ? "nil" : response.response!.debugDescription) data: \((response.data?.length)!) bytes, \(response.timeline)")
        switch response.result {
        case .Success(let value):
            value.rawData = response.data!
            if let httpResponse = response.response {
                value.headers = httpResponse.allHeaderFields
            }
            Log.debug("rest[\(self.tid)]: (Raw String) \(value.rawString == nil ? "nil" : value.rawString!)")
            if !value.isOK {
                Log.error("rest[\(self.tid)]: ResultError[\(value.code)] \(value.errorMessage ?? "")")
            }

            callback(response: value)
        case .Failure(let error):
            let value = RestResponse<T>()
            if let httpResponse = response.response {
                let statusCode = httpResponse.statusCode
                if statusCode >= 200 && statusCode < 400 {
                    Log.error("rest[\(self.tid)]: \(statusCode) Http Request Error")
                    value.error = RestError.httpRequestError(status: statusCode)
                    callback(response: value)
                    stopLoading()
                    return
                }
            }
            Log.error("rest[\(self.tid)]: \(error)")
            value.error = RestError.dataError
            callback(response: value)
        }
    }
}

// MARK: - 标准HTTP Method调用

extension RestRequest {

    /// 调用GET请求
    func get<T>(params: Params? = nil, start: Int? = nil, limit: Int? = nil, callback: (response:RestResponse<T>) -> Void) {
        prepare(params: params, start: start, limit: limit).call(.GET, callback)
    }

    /// 调用POST请求
    func post<T>(params: Params? = nil, start: Int? = nil, limit: Int? = nil, callback: (response:RestResponse<T>) -> Void) {
        prepare(params: params, start: start, limit: limit).call(.POST, callback)
    }

    /// 调用PUT请求
    func put<T>(params: Params? = nil, start: Int? = nil, limit: Int? = nil, callback: (response:RestResponse<T>) -> Void) {
        return prepare(params: params, start: start, limit: limit).call(.PUT, callback)
    }

    /// 调用DELETE请求
    func delete<T>(params: Params? = nil, start: Int? = nil, limit: Int? = nil, callback: (response:RestResponse<T>) -> Void) {
        return prepare(params: params, start: start, limit: limit).call(.DELETE, callback)
    }

}

// MARK: - 载入动画

extension RestRequest {

    private func startLoading() {
        guard let loadingIndicator = loadingIndicator else { return }
        if let quiet = options["quiet"] as? Bool where quiet {
            return
        }
        loadingIndicator.startLoading()
    }

    private func stopLoading() {
        guard let loadingIndicator = loadingIndicator else { return }
        if let quiet = options["quiet"] as? Bool where quiet {
            return
        }
        loadingIndicator.startLoading()
    }

}
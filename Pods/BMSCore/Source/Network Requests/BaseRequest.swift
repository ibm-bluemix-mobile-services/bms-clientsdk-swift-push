/*
*     Copyright 2016 IBM Corp.
*     Licensed under the Apache License, Version 2.0 (the "License");
*     you may not use this file except in compliance with the License.
*     You may obtain a copy of the License at
*     http://www.apache.org/licenses/LICENSE-2.0
*     Unless required by applicable law or agreed to in writing, software
*     distributed under the License is distributed on an "AS IS" BASIS,
*     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
*     See the License for the specific language governing permissions and
*     limitations under the License.
*/



// MARK: - Swift 3

#if swift(>=3.0)

    

/**
    The HTTP method to be used in the `Request` class initializer.
*/
public enum HttpMethod: String {
    
    case GET, POST, PUT, DELETE, TRACE, HEAD, OPTIONS, CONNECT, PATCH
}

    

// MARK: - BMSCompletionHandler

/**
    The type of callback sent with BMS network requests.
*/
public typealias BMSCompletionHandler = (Response?, Error?) -> Void

    
    
    
/**
    Sends HTTP network requests. 
     
    Analytics data is automatically gathered for all requests initiated by this class.

    When building a Request object, all components of the HTTP request must be provided in the initializer, except for the `requestBody`, which can be supplied as Data when sending the request via the `send()` method.
*/
open class BaseRequest: NSObject, URLSessionTaskDelegate {
    
    
    // MARK: Constants
    
    public static let contentType = "Content-Type"
    
    
    
    // MARK: Properties (API)
    
    /// URL that the request is being sent to.
    public private(set) var resourceUrl: String
    
    /// The HTTP method (GET, POST, etc.).
    public let httpMethod: HttpMethod
    
    /// Request timeout measured in seconds.
    public var timeout: Double
    
    /// All request headers.
    public var headers: [String: String] = [:]
    
    /// The query parameters to append to the `resourceURL`.
    public var queryParameters: [String: String]?
    
    /// The request body is set when sending the request via the `send()` method.
    public private(set) var requestBody: Data?
    
    /// Determines whether request should follow HTTP redirects.
    public var allowRedirects : Bool = true
	
	/// Deterimes the cache policy to use for sending request.
	public var cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy
    
    
    
    // MARK: Properties (internal)
    
    // The request timeout is set in this URLSession's configuration.
    // Public access required by BMSSecurity framework.
    public var networkSession: URLSession!
    
    // The time at which the request is sent.
    // Public access required by BMSAnalytics framework.
    public private(set) var startTime: TimeInterval = 0.0
    
    // The unique ID to keep track of each request.
    // Public access required by BMSAnalytics framework.
    public private(set) var trackingId: String = ""
    
    // Metadata for the request.
    // This will obtain a value when the Analytics class from BMSAnalytics is initialized.
    // Public access required by BMSAnalytics framework.
    public static var requestAnalyticsData: String?

    // The current request.
    var networkRequest: URLRequest
    
	private static let logger = Logger.logger(name: Logger.bmsLoggerPrefix + "request")
    
    
    
    // MARK: Initializer
    
    /**
        Creates a new request.

        - parameter url:             The resource URL.
        - parameter method:          The HTTP method.
        - parameter headers:         Optional headers to add to the request.
        - parameter queryParameters: Optional query parameters to add to the request.
        - parameter timeout:         Timeout in seconds for this request.
        - parameter cachePolicy:     Cache policy to use when sending request.
    
        - Note: A relative `url` may be supplied if the `BMSClient` class is initialized with a Bluemix app route beforehand.
    */
    public init(url: String,
               method: HttpMethod = HttpMethod.GET,
               headers: [String: String]? = nil,
               queryParameters: [String: String]? = nil,
               timeout: Double = BMSClient.sharedInstance.requestTimeout,
               cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy) {
        
        // Relative URL
        if (!url.contains("http://") && !url.contains("https://")),
            let bmsAppRoute = BMSClient.sharedInstance.bluemixAppRoute {
                
            self.resourceUrl = bmsAppRoute + url
        }
        // Absolute URL
        else {
            self.resourceUrl = url
        }

        self.httpMethod = method
        if headers != nil {
            self.headers = headers!
        }
        self.timeout = timeout
        self.queryParameters = queryParameters
                
        // Set timeout and initialize network session and request
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = timeout

		self.cachePolicy = cachePolicy
        
        self.networkRequest = URLRequest(url: URL(string: "PLACEHOLDER")!)
		
        super.init()
                
        self.networkSession = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }

    
    
    // MARK: Methods (API)

    /**
        Send the request asynchronously with an optional request body.
        
        The response received from the server is packaged into a `Response` object which is passed back via the supplied completion handler.
    
        If the `resourceUrl` string is a malformed url or if the `queryParameters` cannot be appended to it, the completion handler will be called back with an error and a nil `Response`.
    
        - parameter requestBody: The HTTP request body.
        - parameter completionHandler: The block that will be called when this request finishes.
    */
    public func send(requestBody: Data? = nil, completionHandler: BMSCompletionHandler?) {
        
        self.requestBody = requestBody
		
        // Add metadata to the request header so that analytics data can be obtained for ALL bms network requests
        
        // The analytics server needs this ID to match each request with its corresponding response
        self.trackingId = UUID().uuidString
        headers["x-wl-analytics-tracking-id"] = self.trackingId
        
        if let requestMetadata = BaseRequest.requestAnalyticsData {
            self.headers["x-mfp-analytics-metadata"] = requestMetadata
        }
        
        self.startTime = Date.timeIntervalSinceReferenceDate
        
        if let url = URL(string: self.resourceUrl) {
            
            buildAndSendRequest(url: url, callback: completionHandler)
        }
        else {
            let urlErrorMessage = "The supplied resource url is not a valid url."
            BaseRequest.logger.error(message: urlErrorMessage)
            completionHandler?(nil, BMSCoreError.malformedUrl)
        }
    }
    
    
    
    // MARK: Methods (internal)
    
    private func buildAndSendRequest(url: URL, callback: BMSCompletionHandler?) {
        
        // A callback that builds the Response object and passes it to the user
        let buildAndSendResponse = {
            (data: Data?, response: URLResponse?, error: Error?) -> Void in
            
            let networkResponse = Response(responseData: data, httpResponse: response as? HTTPURLResponse, isRedirect: self.allowRedirects)

            callback?(networkResponse, error)
        }
        
        var requestUrl = url
        
        // Add query parameters to URL
        if queryParameters != nil {
            guard let urlWithQueryParameters = BaseRequest.append(queryParameters: queryParameters!, toURL: requestUrl) else {
                // This scenario does not seem possible due to the robustness of appendQueryParameters(), but it will stay just in case
                let urlErrorMessage = "Failed to append the query parameters to the resource url."
                BaseRequest.logger.error(message: urlErrorMessage)
                callback?(nil, BMSCoreError.malformedUrl)
                return
            }
            requestUrl = urlWithQueryParameters
        }
        
        // Build request
        resourceUrl = String(describing: requestUrl)
        networkRequest.url = requestUrl
        networkRequest.httpMethod = httpMethod.rawValue
        networkRequest.allHTTPHeaderFields = headers
        networkRequest.httpBody = requestBody
		networkRequest.cachePolicy = cachePolicy
        
        BaseRequest.logger.debug(message: "Sending Request to " + resourceUrl)
        
        // Send request
        self.networkSession.dataTask(with: networkRequest, completionHandler: buildAndSendResponse).resume()
    }
    
    
    /**
        Returns the supplied URL with query parameters appended to it; the original URL is not modified.
        Characters in the query parameters that are not URL safe are automatically converted to percent-encoding.
    
        - parameter parameters:  The query parameters to be appended to the end of the url
        - parameter originalURL: The url that the parameters will be appeneded to
    
        - returns: The original URL with the query parameters appended to it
    */
    static func append(queryParameters: [String: String], toURL originalUrl: URL) -> URL? {
        
        if queryParameters.isEmpty {
            return originalUrl
        }
        
        var parametersInURLFormat = [URLQueryItem]()
        for (key, value) in queryParameters {
            parametersInURLFormat += [URLQueryItem(name: key, value: value)]
        }
        
        if var newUrlComponents = URLComponents(url: originalUrl, resolvingAgainstBaseURL: false) {
            if newUrlComponents.queryItems != nil {
                newUrlComponents.queryItems!.append(contentsOf: parametersInURLFormat)
            }
            else {
                newUrlComponents.queryItems = parametersInURLFormat
            }
            return newUrlComponents.url
        }
        else {
            return nil
        }
    }
    
    
    
    // MARK: URLSessionTaskDelegate
    
    // Handle HTTP redirection
    public func urlSession(_ session: URLSession,
                          task: URLSessionTask,
                          willPerformHTTPRedirection response: HTTPURLResponse,
                          newRequest request: URLRequest,
                          completionHandler: @escaping (URLRequest?) -> Void) {
        
        var redirectRequest: URLRequest?
        if allowRedirects {
            BaseRequest.logger.debug(message: "Redirecting: " + String(describing: session))
            redirectRequest = request
        }
        
        completionHandler(redirectRequest)
    }
    
}
    
    
    
    
    
/**************************************************************************************************/
    
    
    
    
    
// MARK: - Swift 2
    
#else
    
    

/**
    The HTTP method to be used in the `Request` class initializer.
*/
public enum HttpMethod: String {

    case GET, POST, PUT, DELETE, TRACE, HEAD, OPTIONS, CONNECT, PATCH
}
    
    
    
// MARK: - BMSCompletionHandler

/**
    The type of callback sent with BMS network requests.
*/
public typealias BMSCompletionHandler = (Response?, NSError?) -> Void
    
    


/**
    Sends HTTP network requests.
     
    Analytics data is automatically gathered for all requests initiated by this class.

    When building a Request object, all components of the HTTP request must be provided in the initializer, except for the `requestBody`, which can be supplied as NSData when sending the request via the `send()` method.
*/
public class BaseRequest: NSObject, NSURLSessionTaskDelegate {
    
    
    // MARK: Constants
    
    public static let contentType = "Content-Type"
    
    
    
    // MARK: Properties (API)
    
    /// URL that the request is being sent to.
    public private(set) var resourceUrl: String
    
    /// The HTTP method (GET, POST, etc.).
    public let httpMethod: HttpMethod
    
    /// Request timeout measured in seconds.
    public var timeout: Double
    
    /// All request headers.
    public var headers: [String: String] = [:]
    
    /// Query parameters to append to the `resourceURL`.
    public var queryParameters: [String: String]?
    
    /// The request body can be set when sending the request via the `send()` method.
    public private(set) var requestBody: NSData?
    
    /// Determines whether request should follow HTTP redirects.
    public var allowRedirects : Bool = true
    
    /// Deterimes the cache policy to use for sending request.
    public var cachePolicy: NSURLRequestCachePolicy = .UseProtocolCachePolicy
    
    
    
    // MARK: Properties (internal)
    
    // The request timeout is set in this URLSession's configuration.
    // Public access required by BMSSecurity framework.
    public var networkSession: NSURLSession!
    
    // The time at which the request is sent.
    // Public access required by BMSAnalytics framework.
    public private(set) var startTime: NSTimeInterval = 0.0
    
    // The unique ID to keep track of each request.
    // Public access required by BMSAnalytics framework.
    public private(set) var trackingId: String = ""
    
    // Metadata for the request.
    // This will obtain a value when the Analytics class from BMSAnalytics is initialized.
    // Public access required by BMSAnalytics framework.
    public static var requestAnalyticsData: String?
    
    // The current request.
    var networkRequest: NSMutableURLRequest
    
    private static let logger = Logger.logger(name: Logger.bmsLoggerPrefix + "request")
    
    
    
    // MARK: Initializer
    
    /**
        Creates a new request.

        - parameter url:             The resource URL.
        - parameter method:          The HTTP method.
        - parameter headers:         Optional headers to add to the request.
        - parameter queryParameters: Optional query parameters to add to the request.
        - parameter timeout:         Timeout in seconds for this request.
        - parameter cachePolicy:	  Cache policy to use when sending request.

        - Note: A relative `url` may be supplied if the `BMSClient` class is initialized with a Bluemix app route beforehand.
    */
    public init(url: String,
               method: HttpMethod = HttpMethod.GET,
               headers: [String: String]? = nil,
               queryParameters: [String: String]? = nil,
               timeout: Double = BMSClient.sharedInstance.requestTimeout,
               cachePolicy: NSURLRequestCachePolicy = NSURLRequestCachePolicy.UseProtocolCachePolicy) {
    
        // Relative URL
        if (!url.containsString("http://") && !url.containsString("https://")),
            let bmsAppRoute = BMSClient.sharedInstance.bluemixAppRoute {
            
            self.resourceUrl = bmsAppRoute + url
        }
        // Absolute URL
        else {
            self.resourceUrl = url
        }
        
        self.httpMethod = method
        if headers != nil {
            self.headers = headers!
        }
        self.timeout = timeout
        self.queryParameters = queryParameters
        
        // Set timeout and initialize network session and request
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.timeoutIntervalForRequest = timeout
        networkRequest = NSMutableURLRequest()
        
        self.cachePolicy = cachePolicy
        
        super.init()
        
        self.networkSession = NSURLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }
    
    
    
    // MARK: Methods (API)
    
    /**
        Send the request asynchronously with an optional request body.

        The response received from the server is packaged into a `Response` object which is passed back via the supplied completion handler.

        If the `resourceUrl` string is a malformed url or if the `queryParameters` cannot be appended to it, the completion handler will be called back with an error and a nil `Response`.

        - parameter requestBody: The HTTP request body.
        - parameter completionHandler: The block that will be called when this request finishes.
    */
    public func send(requestBody requestBody: NSData? = nil, completionHandler: BMSCompletionHandler?) {
        
        self.requestBody = requestBody
    
        // Add metadata to the request header so that analytics data can be obtained for ALL bms network requests
        
        // The analytics server needs this ID to match each request with its corresponding response
        self.trackingId = NSUUID().UUIDString
        headers["x-wl-analytics-tracking-id"] = self.trackingId
        
        if let requestMetadata = BaseRequest.requestAnalyticsData {
            self.headers["x-mfp-analytics-metadata"] = requestMetadata
        }
        
        self.startTime = NSDate.timeIntervalSinceReferenceDate()
        
        if let url = NSURL(string: self.resourceUrl) {
            buildAndSendRequest(url: url, callback: completionHandler)
        }
        else {
            let urlErrorMessage = "The supplied resource url is not a valid url."
            BaseRequest.logger.error(message: urlErrorMessage)
            let malformedUrlError = NSError(domain: BMSCoreError.domain, code: BMSCoreError.malformedUrl.rawValue, userInfo: [NSLocalizedDescriptionKey: urlErrorMessage])
            completionHandler?(nil, malformedUrlError)
        }
    }
    
    
    
    // MARK: Methods (internal)
    
    private func buildAndSendRequest(url url: NSURL, callback: BMSCompletionHandler?) {
    
        // A callback that builds the Response object and passes it to the user
        let buildAndSendResponse = {
            (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
    
            let networkResponse = Response(responseData: data, httpResponse: response as? NSHTTPURLResponse, isRedirect: self.allowRedirects)
            
            callback?(networkResponse as Response, error)
        }
    
        var requestUrl = url
    
        // Add query parameters to URL
        if queryParameters != nil {
            guard let urlWithQueryParameters = BaseRequest.append(queryParameters: queryParameters!, toURL: requestUrl) else {
                // This scenario does not seem possible due to the robustness of appendQueryParameters(), but it will stay just in case
                let urlErrorMessage = "Failed to append the query parameters to the resource url."
                BaseRequest.logger.error(message: urlErrorMessage)
                let malformedUrlError = NSError(domain: BMSCoreError.domain, code: BMSCoreError.malformedUrl.rawValue, userInfo: [NSLocalizedDescriptionKey: urlErrorMessage])
                callback?(nil, malformedUrlError)
                return
            }
            requestUrl = urlWithQueryParameters
        }
        
        // Build request
        resourceUrl = String(requestUrl)
        networkRequest.URL = requestUrl
        networkRequest.HTTPMethod = httpMethod.rawValue
        networkRequest.allHTTPHeaderFields = headers
        networkRequest.HTTPBody = requestBody
        networkRequest.cachePolicy = cachePolicy
        
        BaseRequest.logger.debug(message: "Sending Request to " + resourceUrl)
        
        // Send request
        self.networkSession.dataTaskWithRequest(networkRequest as NSURLRequest, completionHandler: buildAndSendResponse).resume()
    }
    
    
    /**
        Returns the supplied URL with query parameters appended to it; the original URL is not modified.
        Characters in the query parameters that are not URL safe are automatically converted to percent-encoding.

        - parameter parameters:  The query parameters to be appended to the end of the url
        - parameter originalURL: The url that the parameters will be appeneded to

        - returns: The original URL with the query parameters appended to it
    */
    static func append(queryParameters parameters: [String: String], toURL originalUrl: NSURL) -> NSURL? {
    
        if parameters.isEmpty {
            return originalUrl
        }
        
        var parametersInURLFormat = [NSURLQueryItem]()
        for (key, value) in parameters {
            parametersInURLFormat += [NSURLQueryItem(name: key, value: value)]
        }
        
        if let newUrlComponents = NSURLComponents(URL: originalUrl, resolvingAgainstBaseURL: false) {
            if newUrlComponents.queryItems != nil {
                newUrlComponents.queryItems!.appendContentsOf(parametersInURLFormat)
            }
            else {
                newUrlComponents.queryItems = parametersInURLFormat
            }
            return newUrlComponents.URL
        }
        else {
            return nil
        }
    }
    
    
    
    // MARK: NSURLSessionTaskDelegate
    
    // Handle HTTP redirection
    public func URLSession(session: NSURLSession,
                          task: NSURLSessionTask,
                          willPerformHTTPRedirection response: NSHTTPURLResponse,
                          newRequest request: NSURLRequest,
                          completionHandler: ((NSURLRequest?) -> Void)) {
    
        var redirectRequest: NSURLRequest?
        if allowRedirects {
            BaseRequest.logger.debug(message: "Redirecting: " + String(session))
            redirectRequest = request
        }
    
        completionHandler(redirectRequest)
    }
    
}


    
#endif

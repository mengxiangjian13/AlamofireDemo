//
//  ViewController.swift
//  AlamofireDemo
//
//  Created by mengxiangjian on 2021/10/12.
//

import UIKit
import Alamofire
import CommonCrypto

class ViewController: UIViewController,
                      UITableViewDelegate,
                      UITableViewDataSource {
    
    let baseURL = "https://www.baidu.com"
    
    let titles: [[String]] = [[
        "request with url string",
        "specify HTTP method",
        "request with url and request modifier"
    ],[
        "request with parameters",
        "GET: URL encoded paramters",
        "POST: URL encoded paramters",
        "JSON encoded paramters"
    ],[
        "custom headers"
    ],[
        "response validation"
    ],[
        "response handler",
        "response data handler",
        "response string handler",
        "response decodable handler"
    ]]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        view.addSubview(tableView)
        
        let item = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(makeRequestOfLejian))
        navigationItem.rightBarButtonItem = item
    }
    
    lazy var tableView: UITableView = {
        let table = UITableView(frame: view.bounds)
        table.delegate = self
        table.dataSource = self
        table.register(UITableViewCell.self,
                       forCellReuseIdentifier: "cell")
        return table
    }()
    
    // MARK: - tableview delegate datasource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = titles[indexPath.section][indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                makeRequestWithURL()
            case 1:
                makeRequestWithHTTPMethod()
            case 2:
                makeRequestWithRequestModifier()
            default:
                debugPrint("")
            }
        case 1:
            switch indexPath.row {
            case 0:
                makeRequestWithParams()
            case 1:
                makeGETRequestWithURLEncodedParams()
            case 2:
                makePOSTRequestWithURLEncodedParams()
            case 3:
                makeRequestWithJSONEncodedParams()
            default:
                debugPrint("")
            }
        case 2:
            switch indexPath.row {
            case 0:
                makeRequestWithCustomHeaders()
            default:
                debugPrint("")
            }
        case 3:
            switch indexPath.row {
            case 0:
                makeRequestWithResponseValidation()
            default:
                debugPrint("")
            }
        case 4:
            switch indexPath.row {
            case 0:
                makeRequestWithResponseHandler()
            case 1:
                makeRequestWithResponseDataHandler()
            case 2:
                makeRequestWithResponseStringHandler()
            case 3:
                makeRequestWithResponseDecodableHandler()
            default:
                debugPrint("")
            }
        default:
            debugPrint("")
        }
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "request with url"
        case 1:
            return "parameters encode"
        case 2:
            return "headers"
        case 3:
            return "response validation"
        case 4:
            return "response handler"
        default:
            return "request"
        }
    }

}

// 模仿乐见请求
extension ViewController {
    
    /// 乐见请求公共参数是，version和pcode。Header中还有公共验证参数TK，如果登录的情况下，还有ssotk。验证参数TK逻辑见乐见。
    @objc func makeRequestOfLejian() {
        let url = "https://api.leseee.com/v1/wz/zxzq/baseinfo"
        let pcode = "210210000"
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        let params = ["pcode": pcode, "version": version];
        let headers: HTTPHeaders = ["TK": self.lejianTK(url: url, params: params)]
        AF.request(url, parameters: params, headers: headers)
            .validate()
            .responseString { response in
                if let data = response.value {
                    debugPrint(data)
                }
            }
    }
    
    func lejianTK(url: String, params: [String: String]) -> String {
        guard let urlObject = URL(string: url) else { return "" }
        let request = URLRequest(url: urlObject)
        if let r = try? URLEncodedFormParameterEncoder.default.encode(params, into: request), let query = r.url?.query {
            let ts = "1634118283"
            let s = "zCezLmB8o76lk\(ts)\(query)"
            let tk = "\(s.md5).\(ts)"
            return tk
        }
        
        return ""
    }
}

extension String {
    var md5: String {
        let data = Data(self.utf8)
        let hash = data.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) -> [UInt8] in
            var hash = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
            CC_MD5(bytes.baseAddress, CC_LONG(data.count), &hash)
            return hash
        }
        return hash.map { String(format: "%02x", $0) }.joined()
    }
}

// make request
extension ViewController {
    
    struct ParamsModel: Codable {
        let name: String
        let age: Int
    }
    
    struct ResponseModel: Codable {
        let name: String
    }
    
    /// make request with url string, not URLRequestConvertible.
    func makeRequestWithURL() {
        AF.request(baseURL)
            .response { response in
                debugPrint(response)
            }
    }
    
    func makeRequestWithHTTPMethod() {
        AF.request(baseURL, method: .get)
            .response { response in
                debugPrint(response)
            }
    }
    
    /// modifier should be used in request with url string. For request with URLRequestConvertible type, request should be made in URLRequestConvertible themselves.
    
    /// 仅当使用url string来发起请求时，可以使用request modifier。如果使用URLRequestConvertible类型发起请求时，所有的request属性应该在URLRequestConvertible内部定义好。
    func makeRequestWithRequestModifier() {
        AF.request(baseURL) { request in
            request.timeoutInterval = 5
        }
        .response { response in
            debugPrint(response)
        }
    }
    
    func makeRequestWithParams() {
        AF.request(baseURL, parameters: ["param": 1])
            .response { response in
                debugPrint(response)
            }
    }
    
    func makeGETRequestWithURLEncodedParams() {
        let params = ParamsModel(name: "meng", age: 33)
        AF.request(baseURL, parameters: params)
            .response {
                debugPrint($0)
            }
    }
    
    func makePOSTRequestWithURLEncodedParams() {
        let params = ParamsModel(name: "meng", age: 33)
        AF.request(baseURL, method: .post, parameters: params)
            .response {
                debugPrint($0)
                if let httpBody = $0.request?.httpBody {
                    let string = String(data: httpBody, encoding: .utf8)
                    debugPrint("httpbody: \(string ?? "")")
                }
            }
    }
    
    func makeRequestWithJSONEncodedParams() {
        let params = ParamsModel(name: "meng", age: 33)
        AF.request(baseURL, method: .post, parameters: params, encoder: JSONParameterEncoder.default)
            .response {
                debugPrint($0)
                if let httpBody = $0.request?.httpBody {
                    let string = String(data: httpBody, encoding: .utf8)
                    debugPrint("httpbody: \(string ?? "")")
                }
            }
    }
    
    func makeRequestWithCustomHeaders() {
        let headers: HTTPHeaders = ["TK": "fidfajhufejdfslifj"]
        AF.request(baseURL, headers: headers)
            .response {
                debugPrint($0)
            }
    }
    
    func makeRequestWithResponseValidation() {
        AF.request(baseURL)
            .validate(statusCode: 300...400)
            .responseData {
                debugPrint($0)
            }
    }
    
    func makeRequestWithResponseHandler() {
        AF.request(baseURL)
            .response {
                debugPrint($0)
            }
    }
    
    func makeRequestWithResponseDataHandler() {
        AF.request(baseURL)
            .responseData {
                switch $0.result {
                case .success(let data):
                    debugPrint("data will be: \(data)")
                case .failure(let error):
                    debugPrint(error)
                }
            }
    }
    
    func makeRequestWithResponseStringHandler() {
        AF.request(baseURL)
            .responseString {
                switch $0.result {
                case .success(let string):
                    debugPrint("string will be: \(string)")
                case .failure(let error):
                    debugPrint(error)
                }
            }
    }
    
    func makeRequestWithResponseDecodableHandler() {
        AF.request(baseURL)
            .responseDecodable(of: ResponseModel.self) {
                switch $0.result {
                case .success(let object):
                    debugPrint("object will be: \(object)")
                case .failure(let error):
                    debugPrint(error)
                }
            }
    }
}


//
//  ViewController.swift
//  AlamofireDemo
//
//  Created by mengxiangjian on 2021/10/12.
//

import UIKit
import Alamofire

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
    ]]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        view.addSubview(tableView)
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
        default:
            return "request"
        }
    }

}

// make request
extension ViewController {
    
    struct ParamsModel: Codable {
        let name: String
        let age: Int
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
}


import XCTest
import Core

class URLCodableTests: XCTestCase {

    func testParse() throws {
        let data = "value=123&emptyString=&isTrue".data(using: .utf8)!

        struct Test: URLDecodable {
            var value: Int
            var emptyString: String
            var isTrue: Bool
        }

        let test = try Test(urlEncoded: data)
        XCTAssertEqual(test.value, 123)
        XCTAssertEqual(test.emptyString, "")
        XCTAssertEqual(test.isTrue, true)
    }

//    func testFormURLEncoded() {
//        let body = "first=value&arr[]=foo+bar&arr[]=b%3Daz"
//
//        let data = Node(formURLEncoded: body.makeBytes(), allowEmptyValues: true)
//        print(data)
//        XCTAssert(data["first"]?.string == "value", "Request key first did not parse correctly")
//        XCTAssert(data["arr", 0]?.string == "foo bar", "Request key arr did not parse correctly")
//        XCTAssert(data["arr", 1]?.string == "b=az", "Request key arr did not parse correctly")
//    }
//
//    func testFormURLEncodedEdge() {
//        let body = "singleKeyArray[]=value&implicitArray=1&implicitArray=2"
//
//        let data = Node(formURLEncoded: body.makeBytes(), allowEmptyValues: true)
//
//        XCTAssert(data["singleKeyArray", 0]?.string == "value", "singleKeyArray did not parse correctly")
//        XCTAssert(data["implicitArray", 0]?.string == "1", "implicitArray did not parse correctly")
//        XCTAssert(data["implicitArray", 1]?.string == "2", "implicitArray did not parse correctly")
//    }
//
//    func testFormURLEncodedDict() {
//        let body = "obj[foo]=bar&obj[soo]=car"
//        let data = Node(formURLEncoded: body.makeBytes(), allowEmptyValues: true)
//        // FIXME
//        // let foo = try! data.converted(to: JSON.self).makeBytes().makeString()
//        // print(foo)
//        XCTAssertEqual(data["obj.foo"], "bar")
//        XCTAssertEqual(data["obj.foo"], "bar")
//    }
//
//    func testSplitString() {
//        let input = "multipart/form-data; boundary=----WebKitFormBoundaryAzXMX6nUkSI9kQbq"
//        let val = input.components(separatedBy: "boundary=")
//        print("succeeded w/ \(val) because didn't crash")
//    }
//
//    func testEmptyQuery() throws {
//        let req = Request(method: .get, uri: "https://fake.com")
//        req.query = Node([:])
//        XCTAssertNil(req.query)
//    }
//
   static var allTests = [
       ("testParse", testParse),
   ]
}

#!/usr/bin/env bash
set -euo pipefail
repo_root=$(cd "$(dirname "$0")/.." && pwd)
consumer_dir=$(mktemp -d "${TMPDIR:-/tmp}/SwiftCssParserConsumer.XXXXXX")
trap 'rm -rf "$consumer_dir"' EXIT
version=${PACKAGE_VERSION:-}
: "${IOS_SIMULATOR_ID:?Select an available iOS Simulator before running the consumer test}"
python3 - "$repo_root" "$consumer_dir" "$version" <<'PY'
import json, pathlib, re, sys
root, destination, version = sys.argv[1:]
if version and not re.fullmatch(r"\d+\.\d+\.\d+", version):
    raise SystemExit("Expected a semantic version tag")
dependency = '.package(url: "https://github.com/100mango/SwiftCssParser.git", .exact("' + version + '"))' if version else '.package(path: ' + json.dumps(root, ensure_ascii=False) + ')'
p = pathlib.Path(destination)
(p / 'Sources/Consumer').mkdir(parents=True)
(p / 'Tests/ConsumerTests').mkdir(parents=True)
(p / 'Package.swift').write_text('''// swift-tools-version:5.3
import PackageDescription
let package = Package(
    name: "Consumer",
    platforms: [.iOS("9.0")],
    products: [.library(name: "Consumer", targets: ["Consumer"])],
    dependencies: [''' + dependency + '''],
    targets: [
        .target(name: "Consumer", dependencies: [.product(name: "SwiftCssParser", package: "SwiftCssParser")]),
        .testTarget(name: "ConsumerTests", dependencies: ["Consumer"], resources: [.copy("consumer.css")])
    ]
)
''')
PY
cat > "$consumer_dir/Sources/Consumer/Consumer.swift" <<'SWIFT'
import UIKit
import SwiftCssParser

public func width(from url: URL) -> Int { SwiftCSS(CssFileURL: url).int(selector: "#View", key: "width") }
public func color(from url: URL) -> UIColor { SwiftCSS(CssFileURL: url).color(selector: "#View", key: "color") }
public func emptyRuleParses() -> Bool {
    let parser = CssParser(lexer: CssLexer(input: "#Empty { }"))
    parser.parse()
    return parser.outputDic["#Empty"]?.isEmpty == true
}
SWIFT
cat > "$consumer_dir/Tests/ConsumerTests/ConsumerTests.swift" <<'SWIFT'
import XCTest
import UIKit
import Consumer

final class ConsumerTests: XCTestCase {
    func testProductImportsAndReadsConsumersOwnResource() throws {
        let url = try XCTUnwrap(Bundle.module.url(forResource: "consumer", withExtension: "css"))
        XCTAssertEqual(width(from: url), 42)
        XCTAssertEqual(color(from: url), UIColor(red: 1, green: 0, blue: 0, alpha: 1))
        XCTAssertTrue(emptyRuleParses())
    }
}
SWIFT
cat > "$consumer_dir/Tests/ConsumerTests/consumer.css" <<'CSS'
#View { "width": 42; "color": RGB(255,0,0); }
CSS
swift package --package-path "$consumer_dir" resolve
if [[ -n "$version" ]]; then
    python3 - "$consumer_dir/Package.resolved" "$version" "${EXPECTED_REVISION:-}" <<'PY'
import json, sys
path, version, expected = sys.argv[1:]
data = json.load(open(path))
pins = data.get('pins', data.get('object', {}).get('pins', []))
pin = next(p for p in pins if p.get('identity', p.get('package', '')).lower() == 'swiftcssparser')
assert pin['state']['version'] == version, pin
if expected:
    assert pin['state']['revision'] == expected, pin
print('Verified remote version and revision:', pin['state'])
PY
fi
cd "$consumer_dir"
xcodebuild test -scheme Consumer -configuration Release \
    -destination "platform=iOS Simulator,id=$IOS_SIMULATOR_ID" \
    -derivedDataPath "$consumer_dir/DerivedData" \
    -parallel-testing-enabled NO CODE_SIGNING_ALLOWED=NO

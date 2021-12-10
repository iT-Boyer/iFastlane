import Foundation
import PathKit

/// 根目录 ~/hsg/iFastlane
func root() -> Path {
    Path(#file).parent().parent()
}
/// 资源目录
/// - Returns: /Users/boyer/hsg/iFastlane/Resources
func Resources() -> Path {
    root() + "Resources"
}

/// jinher资源目录
/// - Returns: /Users/boyer/hsg/iFastlane/Resources/jinher
func JHSources() -> Path {
    Resources()+"jinher"
}

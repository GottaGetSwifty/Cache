import UIKit

/// Helper UIImage extension.
public extension UIImage {
  /// Checks if image has alpha component
  var hasAlpha: Bool {
    let result: Bool

    guard let alpha = cgImage?.alphaInfo else {
      return false
    }

    switch alpha {
    case .none, .noneSkipFirst, .noneSkipLast:
      result = false
    default:
      result = true
    }

    return result
  }

  /// Convert to data
  func cache_toData() -> Data? {
    #if swift(>=4.2)
    return hasAlpha
      ? pngData()
      : jpegData(compressionQuality: 1.0)
    #else
    return hasAlpha
      ? UIImagePNGRepresentation(self)
      : UIImageJPEGRepresentation(self, 1.0)
    #endif
  }
}

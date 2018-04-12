/// Represents an encoded data-format, used in HTTP, HTML, email, and elsewhere.
///
///     text/plain
///     application/json; charset=utf8
///
/// Description from [rfc2045](https://tools.ietf.org/html/rfc2045#section-5):
///
///     In general, the top-level media type is used to declare the general
///     type of data, while the subtype specifies a specific format for that
///     type of data.  Thus, a media type of "image/xyz" is enough to tell a
///     user agent that the data is an image, even if the user agent has no
///     knowledge of the specific image format "xyz".  Such information can
///     be used, for example, to decide whether or not to show a user the raw
///     data from an unrecognized subtype -- such an action might be
///     reasonable for unrecognized subtypes of text, but not for
///     unrecognized subtypes of image or audio.  For this reason, registered
///     subtypes of text, image, audio, and video should not contain embedded
///     information that is really of a different type.  Such compound
///     formats should be represented using the "multipart" or "application"
///     types.
///
/// Simplified format:
///
///     mediaType := type "/" subtype *(";" parameter)
///     ; Matching of media type and subtype
///     ; is ALWAYS case-insensitive.
///
///     type := token
///
///     subtype := token
///
///     parameter := attribute "=" value
///
///     attribute := token
///     ; Matching of attributes
///     ; is ALWAYS case-insensitive.
///
///     token := 1*<any (US-ASCII) CHAR except SPACE, CTLs,
///         or tspecials>
///
///     value := token
///     ; token MAY be quoted
///
///     tspecials :=  "(" / ")" / "<" / ">" / "@" /
///                   "," / ";" / ":" / "\" / <">
///                   "/" / "[" / "]" / "?" / "="
///     ; Must be in quoted-string,
///     ; to use within parameter values
///
public struct MediaType: Hashable, CustomStringConvertible, Equatable {
    /// See `Equatable`.
    public static func ==(lhs: MediaType, rhs: MediaType) -> Bool {
        guard lhs.type != "*" && rhs.type != "*" else {
            return true
        }

        guard lhs.type != rhs.type else {
            guard lhs.subType != "*" && rhs.subType != "*" else {
                return true
            }

            guard lhs.subType != rhs.subType else {
                return true
            }

            return false
        }

        return false
    }

    /// The `MediaType`'s discrete or composite type. Usually one of the following.
    ///
    ///     "text" / "image" / "audio" / "video" / "application
    ///     "message" / "multipart"
    ///     ...
    ///
    /// In the `MediaType` `"application/json; charset=utf8"`:
    ///
    /// - type: `"application"`
    /// - subtype: `"json"`
    /// - parameters: ["charset": "utf8"]
    public var type: String

    /// The `MediaType`'s specific type. Usually a unique string.
    ///
    /// In the `MediaType` `"application/json; charset=utf8"`:
    ///
    /// - type: `"application"`
    /// - subtype: `"json"`
    /// - parameters: ["charset": "utf8"]
    public var subType: String

    /// The `MediaType`'s metadata. Zero or more key/value pairs.
    ///
    /// In the `MediaType` `"application/json; charset=utf8"`:
    ///
    /// - type: `"application"`
    /// - subtype: `"json"`
    /// - parameters: ["charset": "utf8"]
    public let parameters: [CaseInsensitiveString: String]

    /// Converts this `MediaType` into its string representation.
    ///
    /// For example, the following media type:
    ///
    /// - type: `"application"`
    /// - subtype: `"json"`
    /// - parameters: ["charset": "utf8"]
    ///
    /// Would be converted to `"application/json; charset=utf8"`.
    public func serialize() -> String {
        var string = "\(type)/\(subType)"
        for (key, val) in parameters {
            string += "; \(key)=\(val)"
        }
        return string
    }

    /// See `CustomStringConvertible`.
    public var description: String {
        return serialize()
    }

    /// See `Hashable`.
    public let hashValue: Int

    /// Create a new `MediaType`.
    public init(type: String, subType: String, parameters: [CaseInsensitiveString: String] = [:]) {
        self.type = type
        self.subType = subType
        self.parameters = parameters
        self.hashValue = type.hashValue &+ subType.hashValue
    }

    /// Parse a `MediaType` from a `String`.
    ///
    ///     guard let mediaType = MediaType.parse("application/json; charset=utf8") else { ... }
    ///
    public static func parse(_ data: LosslessDataConvertible) -> MediaType? {
        guard let headerValue = HeaderValue.parse(data) else {
            /// not a valid header value
            return nil
        }

        /// parse out type and subtype
        let typeParts = headerValue._value.split(separator: .forwardSlash, maxSplits: 2)
        guard typeParts.count == 2 else {
            /// the type was not form `foo/bar`
            return nil
        }

        let type = String(data: typeParts[0], encoding: .utf8)?.trimmingCharacters(in: .whitespaces) ?? ""
        let subType = String(data: typeParts[1], encoding: .utf8)?.trimmingCharacters(in: .whitespaces) ?? ""
        
        return MediaType(type: .init(type), subType: .init(subType), parameters: headerValue.parameters)
    }

    /// Creates a `MediaType` from a file extension, if possible.
    ///
    ///     guard let mediaType = MediaType.fileExtension("txt") else { ... }
    ///
    /// - parameters:
    ///     - ext: File extension (ie., "txt", "json", "html").
    /// - returns: Newly created `MediaType`, `nil` if none was found.
    public static func fileExtension(_ ext: String) -> MediaType? {
        return fileExtensionMediaTypeMapping[ext]
    }
}

public extension MediaType {
    /// Any media type (*/*).
    public static let any = MediaType(type: "*", subType: "*")
    /// Plain text media type.
    public static let plainText = MediaType(type: "text", subType: "plain", parameters: ["charset": "utf-8"])
    /// HTML media type.
    public static let html = MediaType(type: "text", subType: "html", parameters: ["charset": "utf-8"])
    /// CSS media type.
    public static let css = MediaType(type: "text", subType: "css", parameters: ["charset": "utf-8"])
    /// URL encoded form media type.
    public static let urlEncodedForm = MediaType(type: "application", subType: "x-www-form-urlencoded", parameters: ["charset": "utf-8"])
    /// Multipart encoded form data.
    public static let formData = MediaType(type: "multipart", subType: "form-data")
    /// Mixed multipart encoded data.
    public static let multipart = MediaType(type: "multipart", subType: "mixed")
    /// JSON media type.
    public static let json = MediaType(type: "application", subType: "json", parameters: ["charset": "utf-8"])
    /// XML media type.
    public static let xml = MediaType(type: "application", subType: "xml", parameters: ["charset": "utf-8"])
    /// DTD media type.
    public static let dtd = MediaType(type: "application", subType: "xml-dtd", parameters: ["charset": "utf-8"])
    /// PDF data.
    public static let pdf = MediaType(type: "application", subType: "pdf")
    /// Zip file.
    public static let zip = MediaType(type: "application", subType: "zip")
    /// tar file.
    public static let tar = MediaType(type: "application", subType: "x-tar")
    /// Gzip file.
    public static let gzip = MediaType(type: "application", subType: "x-gzip")
    /// Bzip2 file.
    public static let bzip2 = MediaType(type: "application", subType: "x-bzip2")
    /// Binary data.
    public static let binary = MediaType(type: "application", subType: "octet-stream")
    /// GIF image.
    public static let gif = MediaType(type: "image", subType: "gif")
    /// JPEG image.
    public static let jpeg = MediaType(type: "image", subType: "jpeg")
    /// PNG image.
    public static let png = MediaType(type: "image", subType: "png")
    /// SVG image.
    public static let svg = MediaType(type: "image", subType: "svg+xml")
    /// Basic audio.
    public static let audio = MediaType(type: "audio", subType: "basic")
    /// MIDI audio.
    public static let midi = MediaType(type: "audio", subType: "x-midi")
    /// MP3 audio.
    public static let mp3 = MediaType(type: "audio", subType: "mpeg")
    /// Wave audio.
    public static let wave = MediaType(type: "audio", subType: "wav")
    /// OGG audio.
    public static let ogg = MediaType(type: "audio", subType: "vorbis")
    /// AVI video.
    public static let avi = MediaType(type: "video", subType: "avi")
    /// MPEG video.
    public static let mpeg = MediaType(type: "video", subType: "mpeg")
}

// MARK: Extensions

let fileExtensionMediaTypeMapping: [String: MediaType] = [
    "ez": MediaType(type: "application", subType: "andrew-inset"),
    "anx": MediaType(type: "application", subType: "annodex"),
    "atom": MediaType(type: "application", subType: "atom+xml"),
    "atomcat": MediaType(type: "application", subType: "atomcat+xml"),
    "atomsrv": MediaType(type: "application", subType: "atomserv+xml"),
    "lin": MediaType(type: "application", subType: "bbolin"),
    "cu": MediaType(type: "application", subType: "cu-seeme"),
    "davmount": MediaType(type: "application", subType: "davmount+xml"),
    "dcm": MediaType(type: "application", subType: "dicom"),
    "tsp": MediaType(type: "application", subType: "dsptype"),
    "es": MediaType(type: "application", subType: "ecmascript"),
    "spl": MediaType(type: "application", subType: "futuresplash"),
    "hta": MediaType(type: "application", subType: "hta"),
    "jar": MediaType(type: "application", subType: "java-archive"),
    "ser": MediaType(type: "application", subType: "java-serialized-object"),
    "class": MediaType(type: "application", subType: "java-vm"),
    "js": MediaType(type: "application", subType: "javascript"),
    "json": MediaType(type: "application", subType: "json"),
    "m3g": MediaType(type: "application", subType: "m3g"),
    "hqx": MediaType(type: "application", subType: "mac-binhex40"),
    "cpt": MediaType(type: "application", subType: "mac-compactpro"),
    "nb": MediaType(type: "application", subType: "mathematica"),
    "nbp": MediaType(type: "application", subType: "mathematica"),
    "mbox": MediaType(type: "application", subType: "mbox"),
    "mdb": MediaType(type: "application", subType: "msaccess"),
    "doc": MediaType(type: "application", subType: "msword"),
    "dot": MediaType(type: "application", subType: "msword"),
    "mxf": MediaType(type: "application", subType: "mxf"),
    "bin": MediaType(type: "application", subType: "octet-stream"),
    "oda": MediaType(type: "application", subType: "oda"),
    "ogx": MediaType(type: "application", subType: "ogg"),
    "one": MediaType(type: "application", subType: "onenote"),
    "onetoc2": MediaType(type: "application", subType: "onenote"),
    "onetmp": MediaType(type: "application", subType: "onenote"),
    "onepkg": MediaType(type: "application", subType: "onenote"),
    "pdf": MediaType(type: "application", subType: "pdf"),
    "pgp": MediaType(type: "application", subType: "pgp-encrypted"),
    "key": MediaType(type: "application", subType: "pgp-keys"),
    "sig": MediaType(type: "application", subType: "pgp-signature"),
    "prf": MediaType(type: "application", subType: "pics-rules"),
    "ps": MediaType(type: "application", subType: "postscript"),
    "ai": MediaType(type: "application", subType: "postscript"),
    "eps": MediaType(type: "application", subType: "postscript"),
    "epsi": MediaType(type: "application", subType: "postscript"),
    "epsf": MediaType(type: "application", subType: "postscript"),
    "eps2": MediaType(type: "application", subType: "postscript"),
    "eps3": MediaType(type: "application", subType: "postscript"),
    "rar": MediaType(type: "application", subType: "rar"),
    "rdf": MediaType(type: "application", subType: "rdf+xml"),
    "rtf": MediaType(type: "application", subType: "rtf"),
    "stl": MediaType(type: "application", subType: "sla"),
    "smi": MediaType(type: "application", subType: "smil+xml"),
    "smil": MediaType(type: "application", subType: "smil+xml"),
    "xhtml": MediaType(type: "application", subType: "xhtml+xml"),
    "xht": MediaType(type: "application", subType: "xhtml+xml"),
    "xml": MediaType(type: "application", subType: "xml"),
    "xsd": MediaType(type: "application", subType: "xml"),
    "xsl": MediaType(type: "application", subType: "xslt+xml"),
    "xslt": MediaType(type: "application", subType: "xslt+xml"),
    "xspf": MediaType(type: "application", subType: "xspf+xml"),
    "zip": MediaType(type: "application", subType: "zip"),
    "apk": MediaType(type: "application", subType: "vnd.android.package-archive"),
    "cdy": MediaType(type: "application", subType: "vnd.cinderella"),
    "kml": MediaType(type: "application", subType: "vnd.google-earth.kml+xml"),
    "kmz": MediaType(type: "application", subType: "vnd.google-earth.kmz"),
    "xul": MediaType(type: "application", subType: "vnd.mozilla.xul+xml"),
    "xls": MediaType(type: "application", subType: "vnd.ms-excel"),
    "xlb": MediaType(type: "application", subType: "vnd.ms-excel"),
    "xlt": MediaType(type: "application", subType: "vnd.ms-excel"),
    "xlam": MediaType(type: "application", subType: "vnd.ms-excel.addin.macroEnabled.12"),
    "xlsb": MediaType(type: "application", subType: "vnd.ms-excel.sheet.binary.macroEnabled.12"),
    "xlsm": MediaType(type: "application", subType: "vnd.ms-excel.sheet.macroEnabled.12"),
    "xltm": MediaType(type: "application", subType: "vnd.ms-excel.template.macroEnabled.12"),
    "eot": MediaType(type: "application", subType: "vnd.ms-fontobject"),
    "thmx": MediaType(type: "application", subType: "vnd.ms-officetheme"),
    "cat": MediaType(type: "application", subType: "vnd.ms-pki.seccat"),
    "ppt": MediaType(type: "application", subType: "vnd.ms-powerpoint"),
    "pps": MediaType(type: "application", subType: "vnd.ms-powerpoint"),
    "ppam": MediaType(type: "application", subType: "vnd.ms-powerpoint.addin.macroEnabled.12"),
    "pptm": MediaType(type: "application", subType: "vnd.ms-powerpoint.presentation.macroEnabled.12"),
    "sldm": MediaType(type: "application", subType: "vnd.ms-powerpoint.slide.macroEnabled.12"),
    "ppsm": MediaType(type: "application", subType: "vnd.ms-powerpoint.slideshow.macroEnabled.12"),
    "potm": MediaType(type: "application", subType: "vnd.ms-powerpoint.template.macroEnabled.12"),
    "docm": MediaType(type: "application", subType: "vnd.ms-word.document.macroEnabled.12"),
    "dotm": MediaType(type: "application", subType: "vnd.ms-word.template.macroEnabled.12"),
    "odc": MediaType(type: "application", subType: "vnd.oasis.opendocument.chart"),
    "odb": MediaType(type: "application", subType: "vnd.oasis.opendocument.database"),
    "odf": MediaType(type: "application", subType: "vnd.oasis.opendocument.formula"),
    "odg": MediaType(type: "application", subType: "vnd.oasis.opendocument.graphics"),
    "otg": MediaType(type: "application", subType: "vnd.oasis.opendocument.graphics-template"),
    "odi": MediaType(type: "application", subType: "vnd.oasis.opendocument.image"),
    "odp": MediaType(type: "application", subType: "vnd.oasis.opendocument.presentation"),
    "otp": MediaType(type: "application", subType: "vnd.oasis.opendocument.presentation-template"),
    "ods": MediaType(type: "application", subType: "vnd.oasis.opendocument.spreadsheet"),
    "ots": MediaType(type: "application", subType: "vnd.oasis.opendocument.spreadsheet-template"),
    "odt": MediaType(type: "application", subType: "vnd.oasis.opendocument.text"),
    "odm": MediaType(type: "application", subType: "vnd.oasis.opendocument.text-master"),
    "ott": MediaType(type: "application", subType: "vnd.oasis.opendocument.text-template"),
    "oth": MediaType(type: "application", subType: "vnd.oasis.opendocument.text-web"),
    "pptx": MediaType(type: "application", subType: "vnd.openxmlformats-officedocument.presentationml.presentation"),
    "sldx": MediaType(type: "application", subType: "vnd.openxmlformats-officedocument.presentationml.slide"),
    "ppsx": MediaType(type: "application", subType: "vnd.openxmlformats-officedocument.presentationml.slideshow"),
    "potx": MediaType(type: "application", subType: "vnd.openxmlformats-officedocument.presentationml.template"),
    "xlsx": MediaType(type: "application", subType: "vnd.openxmlformats-officedocument.spreadsheetml.sheet"),
    "xltx": MediaType(type: "application", subType: "vnd.openxmlformats-officedocument.spreadsheetml.template"),
    "docx": MediaType(type: "application", subType: "vnd.openxmlformats-officedocument.wordprocessingml.document"),
    "dotx": MediaType(type: "application", subType: "vnd.openxmlformats-officedocument.wordprocessingml.template"),
    "cod": MediaType(type: "application", subType: "vnd.rim.cod"),
    "mmf": MediaType(type: "application", subType: "vnd.smaf"),
    "sdc": MediaType(type: "application", subType: "vnd.stardivision.calc"),
    "sds": MediaType(type: "application", subType: "vnd.stardivision.chart"),
    "sda": MediaType(type: "application", subType: "vnd.stardivision.draw"),
    "sdd": MediaType(type: "application", subType: "vnd.stardivision.impress"),
    "sdf": MediaType(type: "application", subType: "vnd.stardivision.math"),
    "sdw": MediaType(type: "application", subType: "vnd.stardivision.writer"),
    "sgl": MediaType(type: "application", subType: "vnd.stardivision.writer-global"),
    "sxc": MediaType(type: "application", subType: "vnd.sun.xml.calc"),
    "stc": MediaType(type: "application", subType: "vnd.sun.xml.calc.template"),
    "sxd": MediaType(type: "application", subType: "vnd.sun.xml.draw"),
    "std": MediaType(type: "application", subType: "vnd.sun.xml.draw.template"),
    "sxi": MediaType(type: "application", subType: "vnd.sun.xml.impress"),
    "sti": MediaType(type: "application", subType: "vnd.sun.xml.impress.template"),
    "sxm": MediaType(type: "application", subType: "vnd.sun.xml.math"),
    "sxw": MediaType(type: "application", subType: "vnd.sun.xml.writer"),
    "sxg": MediaType(type: "application", subType: "vnd.sun.xml.writer.global"),
    "stw": MediaType(type: "application", subType: "vnd.sun.xml.writer.template"),
    "sis": MediaType(type: "application", subType: "vnd.symbian.install"),
    "cap": MediaType(type: "application", subType: "vnd.tcpdump.pcap"),
    "pcap": MediaType(type: "application", subType: "vnd.tcpdump.pcap"),
    "vsd": MediaType(type: "application", subType: "vnd.visio"),
    "wbxml": MediaType(type: "application", subType: "vnd.wap.wbxml"),
    "wmlc": MediaType(type: "application", subType: "vnd.wap.wmlc"),
    "wmlsc": MediaType(type: "application", subType: "vnd.wap.wmlscriptc"),
    "wpd": MediaType(type: "application", subType: "vnd.wordperfect"),
    "wp5": MediaType(type: "application", subType: "vnd.wordperfect5.1"),
    "wk": MediaType(type: "application", subType: "x-123"),
    "7z": MediaType(type: "application", subType: "x-7z-compressed"),
    "abw": MediaType(type: "application", subType: "x-abiword"),
    "dmg": MediaType(type: "application", subType: "x-apple-diskimage"),
    "bcpio": MediaType(type: "application", subType: "x-bcpio"),
    "torrent": MediaType(type: "application", subType: "x-bittorrent"),
    "cab": MediaType(type: "application", subType: "x-cab"),
    "cbr": MediaType(type: "application", subType: "x-cbr"),
    "cbz": MediaType(type: "application", subType: "x-cbz"),
    "cdf": MediaType(type: "application", subType: "x-cdf"),
    "cda": MediaType(type: "application", subType: "x-cdf"),
    "vcd": MediaType(type: "application", subType: "x-cdlink"),
    "pgn": MediaType(type: "application", subType: "x-chess-pgn"),
    "mph": MediaType(type: "application", subType: "x-comsol"),
    "cpio": MediaType(type: "application", subType: "x-cpio"),
    "csh": MediaType(type: "application", subType: "x-csh"),
    "deb": MediaType(type: "application", subType: "x-debian-package"),
    "udeb": MediaType(type: "application", subType: "x-debian-package"),
    "dcr": MediaType(type: "application", subType: "x-director"),
    "dir": MediaType(type: "application", subType: "x-director"),
    "dxr": MediaType(type: "application", subType: "x-director"),
    "dms": MediaType(type: "application", subType: "x-dms"),
    "wad": MediaType(type: "application", subType: "x-doom"),
    "dvi": MediaType(type: "application", subType: "x-dvi"),
    "pfa": MediaType(type: "application", subType: "x-font"),
    "pfb": MediaType(type: "application", subType: "x-font"),
    "gsf": MediaType(type: "application", subType: "x-font"),
    "pcf": MediaType(type: "application", subType: "x-font"),
    "pcf.Z": MediaType(type: "application", subType: "x-font"),
    "woff": MediaType(type: "application", subType: "x-font-woff"),
    "mm": MediaType(type: "application", subType: "x-freemind"),
    "gan": MediaType(type: "application", subType: "x-ganttproject"),
    "gnumeric": MediaType(type: "application", subType: "x-gnumeric"),
    "sgf": MediaType(type: "application", subType: "x-go-sgf"),
    "gcf": MediaType(type: "application", subType: "x-graphing-calculator"),
    "gtar": MediaType(type: "application", subType: "x-gtar"),
    "tgz": MediaType(type: "application", subType: "x-gtar-compressed"),
    "taz": MediaType(type: "application", subType: "x-gtar-compressed"),
    "hdf": MediaType(type: "application", subType: "x-hdf"),
    "hwp": MediaType(type: "application", subType: "x-hwp"),
    "ica": MediaType(type: "application", subType: "x-ica"),
    "info": MediaType(type: "application", subType: "x-info"),
    "ins": MediaType(type: "application", subType: "x-internet-signup"),
    "isp": MediaType(type: "application", subType: "x-internet-signup"),
    "iii": MediaType(type: "application", subType: "x-iphone"),
    "iso": MediaType(type: "application", subType: "x-iso9660-image"),
    "jam": MediaType(type: "application", subType: "x-jam"),
    "jnlp": MediaType(type: "application", subType: "x-java-jnlp-file"),
    "jmz": MediaType(type: "application", subType: "x-jmol"),
    "chrt": MediaType(type: "application", subType: "x-kchart"),
    "kil": MediaType(type: "application", subType: "x-killustrator"),
    "skp": MediaType(type: "application", subType: "x-koan"),
    "skd": MediaType(type: "application", subType: "x-koan"),
    "skt": MediaType(type: "application", subType: "x-koan"),
    "skm": MediaType(type: "application", subType: "x-koan"),
    "kpr": MediaType(type: "application", subType: "x-kpresenter"),
    "kpt": MediaType(type: "application", subType: "x-kpresenter"),
    "ksp": MediaType(type: "application", subType: "x-kspread"),
    "kwd": MediaType(type: "application", subType: "x-kword"),
    "kwt": MediaType(type: "application", subType: "x-kword"),
    "latex": MediaType(type: "application", subType: "x-latex"),
    "lha": MediaType(type: "application", subType: "x-lha"),
    "lyx": MediaType(type: "application", subType: "x-lyx"),
    "lzh": MediaType(type: "application", subType: "x-lzh"),
    "lzx": MediaType(type: "application", subType: "x-lzx"),
    "frm": MediaType(type: "application", subType: "x-maker"),
    "maker": MediaType(type: "application", subType: "x-maker"),
    "frame": MediaType(type: "application", subType: "x-maker"),
    "fm": MediaType(type: "application", subType: "x-maker"),
    "fb": MediaType(type: "application", subType: "x-maker"),
    "book": MediaType(type: "application", subType: "x-maker"),
    "fbdoc": MediaType(type: "application", subType: "x-maker"),
    "md5": MediaType(type: "application", subType: "x-md5"),
    "mif": MediaType(type: "application", subType: "x-mif"),
    "m3u8": MediaType(type: "application", subType: "x-mpegURL"),
    "wmd": MediaType(type: "application", subType: "x-ms-wmd"),
    "wmz": MediaType(type: "application", subType: "x-ms-wmz"),
    "com": MediaType(type: "application", subType: "x-msdos-program"),
    "exe": MediaType(type: "application", subType: "x-msdos-program"),
    "bat": MediaType(type: "application", subType: "x-msdos-program"),
    "dll": MediaType(type: "application", subType: "x-msdos-program"),
    "msi": MediaType(type: "application", subType: "x-msi"),
    "nc": MediaType(type: "application", subType: "x-netcdf"),
    "pac": MediaType(type: "application", subType: "x-ns-proxy-autoconfig"),
    "dat": MediaType(type: "application", subType: "x-ns-proxy-autoconfig"),
    "nwc": MediaType(type: "application", subType: "x-nwc"),
    "o": MediaType(type: "application", subType: "x-object"),
    "oza": MediaType(type: "application", subType: "x-oz-application"),
    "p7r": MediaType(type: "application", subType: "x-pkcs7-certreqresp"),
    "crl": MediaType(type: "application", subType: "x-pkcs7-crl"),
    "pyc": MediaType(type: "application", subType: "x-python-code"),
    "pyo": MediaType(type: "application", subType: "x-python-code"),
    "qgs": MediaType(type: "application", subType: "x-qgis"),
    "shp": MediaType(type: "application", subType: "x-qgis"),
    "shx": MediaType(type: "application", subType: "x-qgis"),
    "qtl": MediaType(type: "application", subType: "x-quicktimeplayer"),
    "rdp": MediaType(type: "application", subType: "x-rdp"),
    "rpm": MediaType(type: "application", subType: "x-redhat-package-manager"),
    "rss": MediaType(type: "application", subType: "x-rss+xml"),
    "rb": MediaType(type: "application", subType: "x-ruby"),
    "sci": MediaType(type: "application", subType: "x-scilab"),
    "sce": MediaType(type: "application", subType: "x-scilab"),
    "xcos": MediaType(type: "application", subType: "x-scilab-xcos"),
    "sh": MediaType(type: "application", subType: "x-sh"),
    "sha1": MediaType(type: "application", subType: "x-sha1"),
    "shar": MediaType(type: "application", subType: "x-shar"),
    "swf": MediaType(type: "application", subType: "x-shockwave-flash"),
    "swfl": MediaType(type: "application", subType: "x-shockwave-flash"),
    "scr": MediaType(type: "application", subType: "x-silverlight"),
    "sql": MediaType(type: "application", subType: "x-sql"),
    "sit": MediaType(type: "application", subType: "x-stuffit"),
    "sitx": MediaType(type: "application", subType: "x-stuffit"),
    "sv4cpio": MediaType(type: "application", subType: "x-sv4cpio"),
    "sv4crc": MediaType(type: "application", subType: "x-sv4crc"),
    "tar": MediaType(type: "application", subType: "x-tar"),
    "tcl": MediaType(type: "application", subType: "x-tcl"),
    "gf": MediaType(type: "application", subType: "x-tex-gf"),
    "pk": MediaType(type: "application", subType: "x-tex-pk"),
    "texinfo": MediaType(type: "application", subType: "x-texinfo"),
    "texi": MediaType(type: "application", subType: "x-texinfo"),
    "~": MediaType(type: "application", subType: "x-trash"),
    "%": MediaType(type: "application", subType: "x-trash"),
    "bak": MediaType(type: "application", subType: "x-trash"),
    "old": MediaType(type: "application", subType: "x-trash"),
    "sik": MediaType(type: "application", subType: "x-trash"),
    "t": MediaType(type: "application", subType: "x-troff"),
    "tr": MediaType(type: "application", subType: "x-troff"),
    "roff": MediaType(type: "application", subType: "x-troff"),
    "man": MediaType(type: "application", subType: "x-troff-man"),
    "me": MediaType(type: "application", subType: "x-troff-me"),
    "ms": MediaType(type: "application", subType: "x-troff-ms"),
    "ustar": MediaType(type: "application", subType: "x-ustar"),
    "src": MediaType(type: "application", subType: "x-wais-source"),
    "wz": MediaType(type: "application", subType: "x-wingz"),
    "crt": MediaType(type: "application", subType: "x-x509-ca-cert"),
    "xcf": MediaType(type: "application", subType: "x-xcf"),
    "fig": MediaType(type: "application", subType: "x-xfig"),
    "xpi": MediaType(type: "application", subType: "x-xpinstall"),
    "amr": MediaType(type: "audio", subType: "amr"),
    "awb": MediaType(type: "audio", subType: "amr-wb"),
    "axa": MediaType(type: "audio", subType: "annodex"),
    "au": MediaType(type: "audio", subType: "basic"),
    "snd": MediaType(type: "audio", subType: "basic"),
    "csd": MediaType(type: "audio", subType: "csound"),
    "orc": MediaType(type: "audio", subType: "csound"),
    "sco": MediaType(type: "audio", subType: "csound"),
    "flac": MediaType(type: "audio", subType: "flac"),
    "mid": MediaType(type: "audio", subType: "midi"),
    "midi": MediaType(type: "audio", subType: "midi"),
    "kar": MediaType(type: "audio", subType: "midi"),
    "mpga": MediaType(type: "audio", subType: "mpeg"),
    "mpega": MediaType(type: "audio", subType: "mpeg"),
    "mp2": MediaType(type: "audio", subType: "mpeg"),
    "mp3": MediaType(type: "audio", subType: "mpeg"),
    "m4a": MediaType(type: "audio", subType: "mpeg"),
    "m3u": MediaType(type: "audio", subType: "mpegurl"),
    "oga": MediaType(type: "audio", subType: "ogg"),
    "ogg": MediaType(type: "audio", subType: "ogg"),
    "opus": MediaType(type: "audio", subType: "ogg"),
    "spx": MediaType(type: "audio", subType: "ogg"),
    "sid": MediaType(type: "audio", subType: "prs.sid"),
    "aif": MediaType(type: "audio", subType: "x-aiff"),
    "aiff": MediaType(type: "audio", subType: "x-aiff"),
    "aifc": MediaType(type: "audio", subType: "x-aiff"),
    "gsm": MediaType(type: "audio", subType: "x-gsm"),
    "wma": MediaType(type: "audio", subType: "x-ms-wma"),
    "wax": MediaType(type: "audio", subType: "x-ms-wax"),
    "ra": MediaType(type: "audio", subType: "x-pn-realaudio"),
    "rm": MediaType(type: "audio", subType: "x-pn-realaudio"),
    "ram": MediaType(type: "audio", subType: "x-pn-realaudio"),
    "pls": MediaType(type: "audio", subType: "x-scpls"),
    "sd2": MediaType(type: "audio", subType: "x-sd2"),
    "wav": MediaType(type: "audio", subType: "x-wav"),
    "alc": MediaType(type: "chemical", subType: "x-alchemy"),
    "cac": MediaType(type: "chemical", subType: "x-cache"),
    "cache": MediaType(type: "chemical", subType: "x-cache"),
    "csf": MediaType(type: "chemical", subType: "x-cache-csf"),
    "cbin": MediaType(type: "chemical", subType: "x-cactvs-binary"),
    "cascii": MediaType(type: "chemical", subType: "x-cactvs-binary"),
    "ctab": MediaType(type: "chemical", subType: "x-cactvs-binary"),
    "cdx": MediaType(type: "chemical", subType: "x-cdx"),
    "cer": MediaType(type: "chemical", subType: "x-cerius"),
    "c3d": MediaType(type: "chemical", subType: "x-chem3d"),
    "chm": MediaType(type: "chemical", subType: "x-chemdraw"),
    "cif": MediaType(type: "chemical", subType: "x-cif"),
    "cmdf": MediaType(type: "chemical", subType: "x-cmdf"),
    "cml": MediaType(type: "chemical", subType: "x-cml"),
    "cpa": MediaType(type: "chemical", subType: "x-compass"),
    "bsd": MediaType(type: "chemical", subType: "x-crossfire"),
    "csml": MediaType(type: "chemical", subType: "x-csml"),
    "csm": MediaType(type: "chemical", subType: "x-csml"),
    "ctx": MediaType(type: "chemical", subType: "x-ctx"),
    "cxf": MediaType(type: "chemical", subType: "x-cxf"),
    "cef": MediaType(type: "chemical", subType: "x-cxf"),
    "emb": MediaType(type: "chemical", subType: "x-embl-dl-nucleotide"),
    "embl": MediaType(type: "chemical", subType: "x-embl-dl-nucleotide"),
    "spc": MediaType(type: "chemical", subType: "x-galactic-spc"),
    "inp": MediaType(type: "chemical", subType: "x-gamess-input"),
    "gam": MediaType(type: "chemical", subType: "x-gamess-input"),
    "gamin": MediaType(type: "chemical", subType: "x-gamess-input"),
    "fch": MediaType(type: "chemical", subType: "x-gaussian-checkpoint"),
    "fchk": MediaType(type: "chemical", subType: "x-gaussian-checkpoint"),
    "cub": MediaType(type: "chemical", subType: "x-gaussian-cube"),
    "gau": MediaType(type: "chemical", subType: "x-gaussian-input"),
    "gjc": MediaType(type: "chemical", subType: "x-gaussian-input"),
    "gjf": MediaType(type: "chemical", subType: "x-gaussian-input"),
    "gal": MediaType(type: "chemical", subType: "x-gaussian-log"),
    "gcg": MediaType(type: "chemical", subType: "x-gcg8-sequence"),
    "gen": MediaType(type: "chemical", subType: "x-genbank"),
    "hin": MediaType(type: "chemical", subType: "x-hin"),
    "istr": MediaType(type: "chemical", subType: "x-isostar"),
    "ist": MediaType(type: "chemical", subType: "x-isostar"),
    "jdx": MediaType(type: "chemical", subType: "x-jcamp-dx"),
    "dx": MediaType(type: "chemical", subType: "x-jcamp-dx"),
    "kin": MediaType(type: "chemical", subType: "x-kinemage"),
    "mcm": MediaType(type: "chemical", subType: "x-macmolecule"),
    "mmd": MediaType(type: "chemical", subType: "x-macromodel-input"),
    "mmod": MediaType(type: "chemical", subType: "x-macromodel-input"),
    "mol": MediaType(type: "chemical", subType: "x-mdl-molfile"),
    "rd": MediaType(type: "chemical", subType: "x-mdl-rdfile"),
    "rxn": MediaType(type: "chemical", subType: "x-mdl-rxnfile"),
    "sd": MediaType(type: "chemical", subType: "x-mdl-sdfile"),
    "tgf": MediaType(type: "chemical", subType: "x-mdl-tgf"),
    "mcif": MediaType(type: "chemical", subType: "x-mmcif"),
    "mol2": MediaType(type: "chemical", subType: "x-mol2"),
    "b": MediaType(type: "chemical", subType: "x-molconn-Z"),
    "gpt": MediaType(type: "chemical", subType: "x-mopac-graph"),
    "mop": MediaType(type: "chemical", subType: "x-mopac-input"),
    "mopcrt": MediaType(type: "chemical", subType: "x-mopac-input"),
    "mpc": MediaType(type: "chemical", subType: "x-mopac-input"),
    "zmt": MediaType(type: "chemical", subType: "x-mopac-input"),
    "moo": MediaType(type: "chemical", subType: "x-mopac-out"),
    "mvb": MediaType(type: "chemical", subType: "x-mopac-vib"),
    "asn": MediaType(type: "chemical", subType: "x-ncbi-asn1"),
    "prt": MediaType(type: "chemical", subType: "x-ncbi-asn1-ascii"),
    "ent": MediaType(type: "chemical", subType: "x-ncbi-asn1-ascii"),
    "val": MediaType(type: "chemical", subType: "x-ncbi-asn1-binary"),
    "aso": MediaType(type: "chemical", subType: "x-ncbi-asn1-binary"),
    "pdb": MediaType(type: "chemical", subType: "x-pdb"),
    "ros": MediaType(type: "chemical", subType: "x-rosdal"),
    "sw": MediaType(type: "chemical", subType: "x-swissprot"),
    "vms": MediaType(type: "chemical", subType: "x-vamas-iso14976"),
    "vmd": MediaType(type: "chemical", subType: "x-vmd"),
    "xtel": MediaType(type: "chemical", subType: "x-xtel"),
    "xyz": MediaType(type: "chemical", subType: "x-xyz"),
    "gif": MediaType(type: "image", subType: "gif"),
    "ief": MediaType(type: "image", subType: "ief"),
    "jp2": MediaType(type: "image", subType: "jp2"),
    "jpg2": MediaType(type: "image", subType: "jp2"),
    "jpeg": MediaType(type: "image", subType: "jpeg"),
    "jpg": MediaType(type: "image", subType: "jpeg"),
    "jpe": MediaType(type: "image", subType: "jpeg"),
    "jpm": MediaType(type: "image", subType: "jpm"),
    "jpx": MediaType(type: "image", subType: "jpx"),
    "jpf": MediaType(type: "image", subType: "jpx"),
    "pcx": MediaType(type: "image", subType: "pcx"),
    "png": MediaType(type: "image", subType: "png"),
    "svg": MediaType(type: "image", subType: "svg+xml"),
    "svgz": MediaType(type: "image", subType: "svg+xml"),
    "tiff": MediaType(type: "image", subType: "tiff"),
    "tif": MediaType(type: "image", subType: "tiff"),
    "djvu": MediaType(type: "image", subType: "vnd.djvu"),
    "djv": MediaType(type: "image", subType: "vnd.djvu"),
    "ico": MediaType(type: "image", subType: "vnd.microsoft.icon"),
    "wbmp": MediaType(type: "image", subType: "vnd.wap.wbmp"),
    "cr2": MediaType(type: "image", subType: "x-canon-cr2"),
    "crw": MediaType(type: "image", subType: "x-canon-crw"),
    "ras": MediaType(type: "image", subType: "x-cmu-raster"),
    "cdr": MediaType(type: "image", subType: "x-coreldraw"),
    "pat": MediaType(type: "image", subType: "x-coreldrawpattern"),
    "cdt": MediaType(type: "image", subType: "x-coreldrawtemplate"),
    "erf": MediaType(type: "image", subType: "x-epson-erf"),
    "art": MediaType(type: "image", subType: "x-jg"),
    "jng": MediaType(type: "image", subType: "x-jng"),
    "bmp": MediaType(type: "image", subType: "x-ms-bmp"),
    "nef": MediaType(type: "image", subType: "x-nikon-nef"),
    "orf": MediaType(type: "image", subType: "x-olympus-orf"),
    "psd": MediaType(type: "image", subType: "x-photoshop"),
    "pnm": MediaType(type: "image", subType: "x-portable-anymap"),
    "pbm": MediaType(type: "image", subType: "x-portable-bitmap"),
    "pgm": MediaType(type: "image", subType: "x-portable-graymap"),
    "ppm": MediaType(type: "image", subType: "x-portable-pixmap"),
    "rgb": MediaType(type: "image", subType: "x-rgb"),
    "xbm": MediaType(type: "image", subType: "x-xbitmap"),
    "xpm": MediaType(type: "image", subType: "x-xpixmap"),
    "xwd": MediaType(type: "image", subType: "x-xwindowdump"),
    "eml": MediaType(type: "message", subType: "rfc822"),
    "igs": MediaType(type: "model", subType: "iges"),
    "iges": MediaType(type: "model", subType: "iges"),
    "msh": MediaType(type: "model", subType: "mesh"),
    "mesh": MediaType(type: "model", subType: "mesh"),
    "silo": MediaType(type: "model", subType: "mesh"),
    "wrl": MediaType(type: "model", subType: "vrml"),
    "vrml": MediaType(type: "model", subType: "vrml"),
    "x3dv": MediaType(type: "model", subType: "x3d+vrml"),
    "x3d": MediaType(type: "model", subType: "x3d+xml"),
    "x3db": MediaType(type: "model", subType: "x3d+binary"),
    "appcache": MediaType(type: "text", subType: "cache-manifest"),
    "ics": MediaType(type: "text", subType: "calendar"),
    "icz": MediaType(type: "text", subType: "calendar"),
    "css": MediaType(type: "text", subType: "css"),
    "csv": MediaType(type: "text", subType: "csv"),
    "323": MediaType(type: "text", subType: "h323"),
    "html": MediaType(type: "text", subType: "html"),
    "htm": MediaType(type: "text", subType: "html"),
    "shtml": MediaType(type: "text", subType: "html"),
    "uls": MediaType(type: "text", subType: "iuls"),
    "mml": MediaType(type: "text", subType: "mathml"),
    "asc": MediaType(type: "text", subType: "plain"),
    "txt": MediaType(type: "text", subType: "plain"),
    "text": MediaType(type: "text", subType: "plain"),
    "pot": MediaType(type: "text", subType: "plain"),
    "brf": MediaType(type: "text", subType: "plain"),
    "srt": MediaType(type: "text", subType: "plain"),
    "rtx": MediaType(type: "text", subType: "richtext"),
    "sct": MediaType(type: "text", subType: "scriptlet"),
    "wsc": MediaType(type: "text", subType: "scriptlet"),
    "tm": MediaType(type: "text", subType: "texmacs"),
    "tsv": MediaType(type: "text", subType: "tab-separated-values"),
    "ttl": MediaType(type: "text", subType: "turtle"),
    "jad": MediaType(type: "text", subType: "vnd.sun.j2me.app-descriptor"),
    "wml": MediaType(type: "text", subType: "vnd.wap.wml"),
    "wmls": MediaType(type: "text", subType: "vnd.wap.wmlscript"),
    "bib": MediaType(type: "text", subType: "x-bibtex"),
    "boo": MediaType(type: "text", subType: "x-boo"),
    "h++": MediaType(type: "text", subType: "x-c++hdr"),
    "hpp": MediaType(type: "text", subType: "x-c++hdr"),
    "hxx": MediaType(type: "text", subType: "x-c++hdr"),
    "hh": MediaType(type: "text", subType: "x-c++hdr"),
    "c++": MediaType(type: "text", subType: "x-c++src"),
    "cpp": MediaType(type: "text", subType: "x-c++src"),
    "cxx": MediaType(type: "text", subType: "x-c++src"),
    "cc": MediaType(type: "text", subType: "x-c++src"),
    "h": MediaType(type: "text", subType: "x-chdr"),
    "htc": MediaType(type: "text", subType: "x-component"),
    "c": MediaType(type: "text", subType: "x-csrc"),
    "d": MediaType(type: "text", subType: "x-dsrc"),
    "diff": MediaType(type: "text", subType: "x-diff"),
    "patch": MediaType(type: "text", subType: "x-diff"),
    "hs": MediaType(type: "text", subType: "x-haskell"),
    "java": MediaType(type: "text", subType: "x-java"),
    "ly": MediaType(type: "text", subType: "x-lilypond"),
    "lhs": MediaType(type: "text", subType: "x-literate-haskell"),
    "moc": MediaType(type: "text", subType: "x-moc"),
    "p": MediaType(type: "text", subType: "x-pascal"),
    "pas": MediaType(type: "text", subType: "x-pascal"),
    "gcd": MediaType(type: "text", subType: "x-pcs-gcd"),
    "pl": MediaType(type: "text", subType: "x-perl"),
    "pm": MediaType(type: "text", subType: "x-perl"),
    "py": MediaType(type: "text", subType: "x-python"),
    "scala": MediaType(type: "text", subType: "x-scala"),
    "etx": MediaType(type: "text", subType: "x-setext"),
    "sfv": MediaType(type: "text", subType: "x-sfv"),
    "tk": MediaType(type: "text", subType: "x-tcl"),
    "tex": MediaType(type: "text", subType: "x-tex"),
    "ltx": MediaType(type: "text", subType: "x-tex"),
    "sty": MediaType(type: "text", subType: "x-tex"),
    "cls": MediaType(type: "text", subType: "x-tex"),
    "vcs": MediaType(type: "text", subType: "x-vcalendar"),
    "vcf": MediaType(type: "text", subType: "x-vcard"),
    "3gp": MediaType(type: "video", subType: "3gpp"),
    "axv": MediaType(type: "video", subType: "annodex"),
    "dl": MediaType(type: "video", subType: "dl"),
    "dif": MediaType(type: "video", subType: "dv"),
    "dv": MediaType(type: "video", subType: "dv"),
    "fli": MediaType(type: "video", subType: "fli"),
    "gl": MediaType(type: "video", subType: "gl"),
    "mpeg": MediaType(type: "video", subType: "mpeg"),
    "mpg": MediaType(type: "video", subType: "mpeg"),
    "mpe": MediaType(type: "video", subType: "mpeg"),
    "ts": MediaType(type: "video", subType: "MP2T"),
    "mp4": MediaType(type: "video", subType: "mp4"),
    "qt": MediaType(type: "video", subType: "quicktime"),
    "mov": MediaType(type: "video", subType: "quicktime"),
    "ogv": MediaType(type: "video", subType: "ogg"),
    "webm": MediaType(type: "video", subType: "webm"),
    "mxu": MediaType(type: "video", subType: "vnd.mpegurl"),
    "flv": MediaType(type: "video", subType: "x-flv"),
    "lsf": MediaType(type: "video", subType: "x-la-asf"),
    "lsx": MediaType(type: "video", subType: "x-la-asf"),
    "mng": MediaType(type: "video", subType: "x-mng"),
    "asf": MediaType(type: "video", subType: "x-ms-asf"),
    "asx": MediaType(type: "video", subType: "x-ms-asf"),
    "wm": MediaType(type: "video", subType: "x-ms-wm"),
    "wmv": MediaType(type: "video", subType: "x-ms-wmv"),
    "wmx": MediaType(type: "video", subType: "x-ms-wmx"),
    "wvx": MediaType(type: "video", subType: "x-ms-wvx"),
    "avi": MediaType(type: "video", subType: "x-msvideo"),
    "movie": MediaType(type: "video", subType: "x-sgi-movie"),
    "mpv": MediaType(type: "video", subType: "x-matroska"),
    "mkv": MediaType(type: "video", subType: "x-matroska"),
    "ice": MediaType(type: "x-conference", subType: "x-cooltalk"),
    "sisx": MediaType(type: "x-epoc", subType: "x-sisx-app"),
    "vrm": MediaType(type: "x-world", subType: "x-vrml"),
]

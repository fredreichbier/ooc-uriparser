include uriparser/Uri

ErrorCode: cover from Int {
    success: func -> Bool {
        return this == 0
    }
}

ParserStateStruct: cover from UriParserStateA {
    uri: extern Uri
    errorCode: extern Int
    errorPos: extern const Char*
    reserved: extern Pointer
}

ParserState: cover from ParserStateStruct* {
    new: static func -> This {
        this := gc_malloc(ParserStateStruct size) as ParserState
        this@ uri = null
        return this
    }
    parseEx: extern(uriParseUriExA) func (first, last: const Char*) -> ErrorCode
    parse: extern(uriParseUriA) func (text: const Char*) -> ErrorCode
}

TextRange: cover from UriTextRangeA {
    first, afterLast: extern const Char*
    copy: func -> String {
        ret := String new(afterLast - first)
        memcpy(ret, first, afterLast - first)
        return ret
    }
}

UriStruct: cover from UriUriA {
    scheme, userInfo, hostText, hostData, portText: extern TextRange
    pathHead, pathTail: extern PathSegment*
    query, fragment: extern TextRange
    absolutePath, owner: extern Bool
    reserved: extern Pointer
}

PathSegment: cover from UriPathSegmentA {
    text: extern TextRange
    next: extern PathSegment*
    reserved: extern Pointer
}

QueryListStruct: cover from UriQueryListA {
    key, value: extern const String
    next: extern QueryList
}

uriComposeQueryExA: extern func (Char*, QueryList, Int, Int*, Bool, Bool) -> ErrorCode

QueryList: cover from QueryListStruct* {
    charsRequired: extern(uriComposeQueryCharsRequiredA) func (charsRequired: Int*) -> ErrorCode
    charsRequiredEx: extern(uriComposeQueryCharsRequiredExA) func (charsRequired: Int*, spaceToPlus, normalizeBreaks: Bool) -> ErrorCode
    composeEx: func (dest: String, maxChars: Int, charsWritten: Int*, spaceToPlus, normalizeBreaks: Bool) -> ErrorCode {
        return uriComposeQueryExA(dest, this, maxChars, charsWritten, spaceToPlus, normalizeBreaks)
    }
}

uriToStringA: extern func (String, Uri, Int, Int*) -> ErrorCode

Uri: cover from UriStruct* {
    new: static func -> This {
        this := gc_malloc(UriStruct size) as Uri
        return this
    }
    freeMembers: extern(uriFreeUriMembersA) func
    normalizeSyntax: extern(uriNormalizeSyntaxA) func -> ErrorCode
    normalizeSyntaxEx: extern(uriNormalizeSyntaxExA) func (mask: UInt) -> ErrorCode 
    normalizeSyntaxMaskRequired: extern(uriNormalizeSyntaxMaskRequiredA) func -> UInt
    removeBase: extern(uriRemoveBaseUriA) func (absoluteSource, absoluteBase: const This, domainRootMode: Bool) -> UInt
    toString: func (dest: String, maxChars: Int, charsWritten: Int*) -> ErrorCode {
        return uriToStringA(dest, this, maxChars, charsWritten)
    }
    /** return the uri as string or null in case of error */
    toString: func ~lazy -> String {
        charsRequired := toStringCharsRequired()
        if(charsRequired != -1) {
            dest := String new(charsRequired)
            charsWritten: Int
            toString(dest, charsRequired, charsWritten&)
            /* TODO: can `charsWritten` be < charsRequired? */
            return dest
        } else {
            return null
        }
    }
    toStringCharsRequired: extern(uriToStringCharsRequiredA) func (charsRequired: Int*) -> ErrorCode
    /** return the number of chars required or -1 in case of error */
    toStringCharsRequired: func ~lazy -> UInt {
        charsRequired: Int
        if(toStringCharsRequired(charsRequired&) success()) {
            return charsRequired
        } else {
            return -1
        }
    }
}

BreakConversion: cover {
    toLf: extern(URI_BR_TO_LF) static const Int
    toCrLf: extern(URI_BR_TO_CRLF) static const Int
    toCr: extern(URI_BR_TO_CR) static const Int
    toUnix: extern(URI_BR_TO_UNIX) static const Int
    toWindows: extern(URI_BR_TO_WINDOWS) static const Int
    toMac: extern(URI_BR_TO_CR) static const Int
    dontTouch: extern(URI_BR_DONT_TOUCH) static const Int
}

NormalizationMask: cover {
    normalized: extern(URI_NORMALIZED) static const Int
    normalizeScheme: extern(URI_NORMALIZE_SCHEME) static const Int
    normalizeUserInfo: extern(URI_NORMALIZE_USER_INFO) static const Int
    normalizeHost: extern(URI_NORMALIZE_HOST) static const Int
    normalizePath: extern(URI_NORMALIZE_PATH) static const Int
    normalizeQuery: extern(URI_NORMALIZE_QUERY) static const Int
    normalizeFragment: extern(URI_NORMALIZE_FRAGMENT) static const Int
}

unescapeInPlace: extern(uriUnescapeInPlaceA) func (inout: String) -> Char*
unescapeInPlaceEx: extern(uriUnescapeInPlaceExA) func (inout: String, plusToSpace: Bool, breakConversion: Int) -> Char*
unixFilenameToUriString: extern(uriUnixFilenameToUriStringA) func (filename: const String, uriString: String) -> ErrorCode
stringToUnixFilename: extern(uriUriStringToUnixFilenameA) func (uriString: const String, filename: String) -> ErrorCode
windowsFilenameToUriString: extern(uriWindowsFilenameToUriStringA) func (filename: const String, uriString: String) -> ErrorCode
stringToWindowsFilename: extern(uriUriStringToWindowsFilenameA) func (uriString: const String, filename: String) -> ErrorCode


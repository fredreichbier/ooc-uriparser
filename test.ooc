use uriparser

import uriparser/UriParser

main: func {
    state := ParserState new()
    uri := Uri new()
    state@ uri = uri
    state parse("http://ooc-lang.org/hello/world.ooc?oompa=loompa#mark")
    uri@ query copy() println()
}

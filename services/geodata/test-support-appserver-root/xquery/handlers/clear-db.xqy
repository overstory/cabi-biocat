xquery version "1.0-ml";

(:
	DANGER!  This XQuery will delete everything in the named collection.  Be Careful
:)

import module namespace const = "urn:cabi.org:namespace:module:constants" at "constants.xqy";

xdmp:collection-delete ($const:collection-name),
xdmp:set-response-code (204, "DB Cleared")


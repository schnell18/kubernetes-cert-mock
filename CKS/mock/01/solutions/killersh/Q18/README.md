# Solution

The kubernetes audit log is stored as json, one line per event.
So we can filter logs with grep then use jq to see details.

    cat audit.log | grep p.auster | grep Secret | jq

Then identified exposed secret in "objectRef".

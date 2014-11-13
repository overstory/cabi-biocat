#!/bin/sh

MLCPBIN=/Users/ron/Work/cabi/abstracts/ingestion/mlcp-Hadoop2-1.2-3/bin
INPUTDIR=/Users/ron/Work/cabi/abstracts/ingestion/samples/as-exported

URIPREFIX=/abstracts
XFORMMOD=/transform-abstract.xqy
XFORMNS=http://cabi.org/transform

$MLCPBIN/mlcp.sh import -mode local -host localhost -port 12101 -username admin -password admin \
	-input_file_path $INPUTDIR -output_uri_prefix $URIPREFIX  -output_uri_replace "$INPUTDIR,''" \
	-transform_module $XFORMMOD -transform_namespace $XFORMNS

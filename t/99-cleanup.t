#!perl -T

use strict;
use warnings;

use Test::More tests => 2;

SKIP:
{
	skip( 'Temporary dashboard id file does not exist.', 1 )
		if ! -e 'webservice-datadog-dashboard-dashid.tmp';

	ok(
		unlink( 'webservice-datadog-dashboard-dashid.tmp' ),
		'Remove temporary dashboard id file',
	);
}

SKIP:
{
	skip( 'Temporary host tag id file does not exist.', 1 )
		if ! -e 'webservice-datadog-tags-hostid.tmp';

	ok(
		unlink( 'webservice-datadog-tags-hostid.tmp' ),
		'Remove temporary dashboard id file',
	);
}

#!perl -T

use strict;
use warnings;

use Test::More tests => 2;

SKIP:
{
	skip( 'Temporary dashboard id file does not exist.', 1 )
		if ! -e 'business-datadog-dashboard-dashid.tmp';

	ok(
		unlink( 'business-datadog-dashboard-dashid.tmp' ),
		'Remove temporary dashboard id file',
	);
}

SKIP:
{
	skip( 'Temporary host tag id file does not exist.', 1 )
		if ! -e 'business-datadog-tags-hostid.tmp';

	ok(
		unlink( 'business-datadog-tags-hostid.tmp' ),
		'Remove temporary dashboard id file',
	);
}

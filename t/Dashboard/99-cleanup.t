#!perl -T

use strict;
use warnings;

use Test::More tests => 1;

SKIP:
{
	skip( 'Temporary dashboard id file does not exist.', 1 )
		if ! -e 'webservice-datadog-dashboard-dashid.tmp';

	ok(
		unlink( 'webservice-datadog-dashboard-dashid.tmp' ),
		'Remove temporary dashboard id file',
	);
}


#!perl -T

use strict;
use warnings;

use Test::More tests => 1;

SKIP:
{
	skip( 'Temporary event id file does not exist.', 1 )
		if ! -e 'webservice-datadog-events-eventid.tmp';

	ok(
		unlink( 'webservice-datadog-events-eventid.tmp' ),
		'Remove temporary event id file',
	);
}


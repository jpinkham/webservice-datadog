#!perl -T

use strict;
use warnings;

use Data::Dumper;
use Data::Validate::Type;
use Test::Exception;
use Test::More;
use WebService::DataDog;


eval 'use DataDogConfig';
$@
	? plan( skip_all => 'Local connection information for DataDog required to run tests.' )
	: plan( tests => 8 );

my $config = DataDogConfig->new();

# Update an object to communicate with DataDog
my $datadog = WebService::DataDog->new( %$config );
ok(
	defined( $datadog ),
	'Update a new WebService::DataDog object.',
);


my $tag_obj = $datadog->build('Tag');
ok(
	defined( $tag_obj ),
	'Update a new WebService::DataDog::Tag object.',
);



my $host;
ok(
	open( FILE, 'webservice-datadog-tag-host.tmp'),
	'Open temp file to read host.'
);

ok(
	$host = do { local $/; <FILE> },
	'Read in host name/id.'
);

ok(
	close FILE,
	'Close temp file.'
);

my $response;

throws_ok(
	sub
	{
		$response = $tag_obj->update();
	},
	qr/Argument.*required/,
	'Dies without required arguments',
);

throws_ok(
	sub {
		$response = $tag_obj->update(
			host => $host,
			tags  => {},
		);
	},
	qr/nvalid 'tags'.*Must be an arrayref/,
	'Dies with invalid tag list, not an arrayref.',
);


lives_ok(
	sub
	{
		$response = $tag_obj->update(
			host => $host,
			tags => [ 'testing_tag' ],
		);
	},
	'Update tags attached to specified host.',
)|| diag explain $response;

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
	: plan( tests => 7 );

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
		$response = $tag_obj->delete();
	},
	qr/Argument.*required/,
	'Dies without required arguments',
);

lives_ok(
	sub
	{
		$response = $tag_obj->delete(
			host => $host,
		);
	},
	'Remove all tags from the specified host.',
)|| diag explain $response;

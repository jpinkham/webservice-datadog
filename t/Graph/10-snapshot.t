#!perl -T

use strict;
use warnings;

use Data::Dumper;
use Data::Validate::Type;
use Test::Exception;
use Test::Most 'bail';
use WebService::DataDog;


eval 'use DataDogConfig';
$@
	? plan( skip_all => 'Local connection information for DataDog required to run tests.' )
	: plan( tests => 4 );

my $config = DataDogConfig->new();

# Create an object to communicate with DataDog
my $datadog = WebService::DataDog->new( %$config );
ok(
	defined( $datadog ),
	'Create a new WebService::DataDog object.',
);


my $graph_obj = $datadog->build('Graph');
ok(
	defined( $graph_obj ),
	'Create a new WebService::DataDog::Graph object.',
);

my $response;

throws_ok(
	sub
	{
		$response = $graph_obj->snapshot();
	},
	qr/Argument.*required/,
	'Dies without required arguments',
);


throws_ok(
	sub
	{
		$response = $graph_obj->snapshot(
			metric_query     => "system.load.1{*}",
			start            => "abcd",
			end              => 12345
		);
	},
	qr/'start' must be an integer/,
	'Dies on invalid start time',
);


#**    [CommentBlockStart     (April 12, 2015 11:25:24 AM EDT, jpinkham)
#**+----------------------------------------------------------------------
#**|throws_ok(
#**|	sub
#**|	{
#**|		$response = $graph_obj->snapshot(
#**|			metric_query     => "system.load.1{*}",
#**|			start            => 12345,
#**|			end              => "abcd"
#**|		);
#**|	},
#**|	qr/'end' must be an integer/,
#**|	'Dies on invalid end time',
#**|);
#**+----------------------------------------------------------------------
#**    CommentBlockEnd]       (April 12, 2015 11:25:24 AM EDT, jpinkham)


#**    [CommentBlockStart     (April 12, 2015 10:59:14 AM EDT, jpinkham)
#**+----------------------------------------------------------------------
#**|lives_ok(
#**|	sub
#**|	{
#**|		$response = $comment_obj->create(
#**|			message          => "Unit test for WebService::DataDog -- Message goes here",
#**|		);
#**|	},
#**|	'Create new comment - no related event.',
#**|)|| diag explain $response;
#**|
#**|ok(
#**|	Data::Validate::Type::is_hashref( $response ),
#**|	'Response is a hashref.',
#**|);
#**|
#**|
#**|# Store id for use in upcoming tests
#**|
#**|ok(
#**|	open( FILE, '>', 'webservice-datadog-comment-commentid.tmp'),
#**|	'Open temp file to store new comment id'
#**|);
#**|
#**|print FILE $response->{'id'};#$new_comment_id;
#**|
#**|
#**|
#**|ok(
#**|	close FILE,
#**|	'Close temp file'
#**|);
#**+----------------------------------------------------------------------
#**    CommentBlockEnd]       (April 12, 2015 10:59:14 AM EDT, jpinkham)


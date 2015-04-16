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
	: plan( tests => 10 );

my $config = DataDogConfig->new();

# Create an object to communicate with DataDog
my $datadog = WebService::DataDog->new( %$config );
ok(
	defined( $datadog ),
	'Create a new WebService::DataDog object.',
);


my $comment_obj = $datadog->build('Comment');
ok(
	defined( $comment_obj ),
	'Create a new WebService::DataDog::Comment object.',
);

my $response;

throws_ok(
	sub
	{
		$response = $comment_obj->create();
	},
	qr/Argument.*required/,
	'Dies without required arguments',
);


throws_ok(
	sub
	{
		$response = $comment_obj->create(
			message          => "testing comment 1 2 3",
			related_event_id => "abcd",
		);
	},
	qr/'related_event_id' must be an integer/,
	'Dies on invalid related event id',
);



lives_ok(
	sub
	{
		$response = $comment_obj->create(
			message          => "Unit test for WebService::DataDog -- Message goes here",
		);
	},
	'Create new comment - no related event.',
)|| diag explain $response;

ok(
	Data::Validate::Type::is_hashref( $response ),
	'Response is a hashref.',
);

# BROKEN(4/11/2015) - Add a comment to thread of message we just created

#**    [CommentBlockStart     (April 11, 2015 8:08:13 PM EDT, jpinkham)
#**+----------------------------------------------------------------------
#**|my $event_id = $response->{'id'};
#**|#hardcode. for testing
#**|#$event_id = "2760155822150389761";
#**|
#**|lives_ok(
#**|	sub
#**|	{
#**|		$response = $comment_obj->create(
#**|			message          => "Message2 goes here",
#**|			related_event_id => $event_id,
#**|		);
#**|	},
#**|	'Create new comment - specifying related event.',
#**|)|| diag explain $response;
#**|
#**|my $new_comment_id = $response->{'id'};
#**|
#**|is(
#**|	$response->{'related_event_id'},
#**|	$event_id,
#**|	'Comment added to existing thread.'
#**|);
#**|
#**+----------------------------------------------------------------------
#**    CommentBlockEnd]       (April 11, 2015 8:08:13 PM EDT, jpinkham)

my $related_comment = $response->{'resource'};

lives_ok(
	sub
	{
		$response = $comment_obj->create(
			message           => 'WebService::DataDog::Comment unit test - message2',
			related_event_url => $related_comment,
		);
	},
	'Create new comment - specifying related event.',
)|| diag explain $response;

is(
	$response->{'resource'},
	$related_comment,
	'Comment added to existing thread.'
);
	

# Store id for use in upcoming tests

ok(
	open( FILE, '>', 'webservice-datadog-comment-commenturl.tmp'),
	'Open temp file to store new comment URL'
);

print FILE $response->{'resource'};#$new_comment_id;

ok(
	close FILE,
	'Close temp file'
);

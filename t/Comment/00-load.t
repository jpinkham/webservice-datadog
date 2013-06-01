#!perl -T

use Test::More tests => 1;

BEGIN
{
	use_ok( 'WebService::DataDog::Comment' );
}

diag( "Testing WebService::DataDog::Comment $WebService::DataDog::VERSION, Perl $], $^X" );

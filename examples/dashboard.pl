#!/usr/bin/perl

use strict;
use warnings;

use WebService::DataDog;
use Try::Tiny;
use Data::Dumper;


my $datadog = WebService::DataDog->new(
	api_key         => 'YOUR_API_KEY',
	application_key => 'YOUR_APPLICATION_KEY',
#	verbose         => 1,
);


my $dashboard = $datadog->build('Dashboard');
my $dashboard_list;
try
{
	$dashboard_list = $dashboard->get_all_dashboards();
}
catch
{
	print "FAILED - Couldn't retrieve dashboards because: @_ \n";
};

print "Dashboard list:\n", Dumper($dashboard_list);


try
{
	$dashboard->update_dashboard(
		id    => '504',
		title => "New title here",
	);
}
catch
{
	print "FAILED - Could not update dashboard title because: @_ \n";
};


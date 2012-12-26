package WebService::DataDog;

use strict;
use warnings;

use Data::Dumper;
use LWP::UserAgent qw();
use HTTP::Request qw();
use JSON qw();
use Class::Load qw();
use Carp qw( carp croak );
use Data::Validate::Type qw();


our $API_ENDPOINT = "https://app.datadoghq.com/api/v1/";


=head1 NAME

WebService::DataDog - Interface to DataDog's REST API.


=head1 VERSION

Version 0.2.0

=cut

our $VERSION = '0.2.0';


=head1 SYNOPSIS

This module allows you to interact with DataDog, a service that will "Capture
metrics and events, then graph, filter, and search to see what's happening and 
how systems interact." This module encapsulates all the communications with the
REST API provided by DataDog to offer a Perl interface to metrics, dashboards,
events, alerts, etc.

Requests that write data require reporting access and require an API key.
Requests that read data require full access and additionally require an
application key.

	use WebService::DataDog;
	
	# Create an object to communicate with DataDog
	my $datadog = WebService::DataDog->new(
		api_key         => 'your_api_key_here',
		application_key => 'your_application_key',
	);
	
	# For metrics functions, first build a metrics object
	my $metric = $datadog->build('Metric');
	
	# To post metrics (past or present)
	# NOTE: only use 'value' OR 'data_points', but not both.
	$metric->post_metric(
		name        => $metric_name,
		type        => $metric_type,  # Optional - gauge|counter. Default=gauge.
		value       => $metric_value, # For posting a single data point, time 'now'
		data_points => $data_points,  # 1+ data points, with timestamps
		host        => $hostname,     # Optional - host that produced the metric
		tags        => $tag_list,     # Optional - tags associated with the metric
	);
	
	# For dashboard functions, first build a dashboard object
	my $dashboard = $datadog->build('Dashboard');
	
	# To make any changes to an existing user-created dashboard:
	# Specify dash_id and any combination of title, description, graphs
	$dashboard->update_dashboard(
		id          => $dash_id,
		title       => $dash_title,
		description => $dash_description,
		graphs      => $graphs,
	);
	
=cut


=head1 METHODS

=head2 new()

Create a new DataDog object that will be used as the interface with
DataDog's API

	use WebService::DataDog;
	
	# Create an object to communicate with DataDog
	my $datadog = WebService::DataDog->new(
		api_key         => 'your_api_key_here',
		application_key => 'your_application_key',
		verbose         => 1,
	);

Creates a new object to communicate with DataDog.

The 'verbose' parameter is optional and defaults to not verbose.

=cut

sub new
{
	my ( $class, %args ) = @_;
	
	# Check for mandatory parameters
	foreach my $arg ( qw( api_key application_key ) )
	{
		croak "Argument '$arg' is needed to create the WebService::DataDog object"
			if !defined( $args{$arg} ) || ( $args{$arg} eq '' );
	}
	
	# Create the object
	my $self = bless(
		{
			api_key         => $args{'api_key'},
			application_key => $args{'application_key'},
		},
		$class,
	);
	
	$self->verbose( $args{'verbose'} );
	
	return $self;
}


=head2 build()

Create a WebService::DataDog::* object with the correct connection parameters.

		# Use the factory to get a WebService::DataDog::* object with
		# the correct DataDog connection parameters.
		my $metric = $datadog->build( 'Metric' );

Parameters:

=over

=item *

The submodule name, such as Metric for WebService::DataDog::Metric.

=back

=cut

sub build
{
		my ( $self, $module ) = @_;
		
		# Check required arguments
		croak 'Please specify the name of the module to build'
			if !defined( $module ) || ( $module eq '' );
		
		my $class = __PACKAGE__ . '::' . $module;
		
		Class::Load::load_class( $class ) || croak "Failed to load $class, double-check the class name";
		my $object = bless( $self, $class ); # Copy internals of factory so we have connection information
		return $object;
}


=head2 verbose()

Get or set the 'verbose' property.

	my $verbose = $self->verbose();
	$self->verbose( 1 );

=cut

sub verbose
{
	my ( $self, $value ) = @_;
	
	if ( defined $value && $value =~ /^[01]$/ )
	{
		$self->{'verbose'} = $value;
	}
	else
	{
		return $self->{'verbose'};
	}
	
	return;
}



=head1 RUNNING TESTS

By default, only basic tests that do not require a connection to DataDog's
platform are run in t/.

To run the developer tests, you will need to do the following:

=over 4

=item * Sign up to become a DataDog customer ( if you are not already), at
L<https://app.datadoghq.com/signup>. Free trial accounts are available.

=item * Generate an application key at
L<https://app.datadoghq.com/account/settings#api>

=back

You can now create a file named DataDogConfig.pm in your own directory, with
the following content:

	package DataDogConfig;
	
	sub new
	{
		return
		{
			api_key         => 'your_api_key',
			application_key => 'your_application_key',
			verbose         => 0, # Enable this for debugging output
		};
	}
	
	1;

You will then be able to run all the tests included in this distribution, after
adding the path to DataDogConfig.pm to your library paths.




=head1 INTERNAL METHODS

=head2 _send_request()


=cut
sub _send_request ## no critic qw( Subroutines::ProhibitUnusedPrivateSubroutines )
{
	my ( $self, %args ) = @_;
	my $verbose = $self->verbose();
	
	# Check for mandatory parameters
	foreach my $arg ( qw( data method url ) )
	{
		croak "Argument '$arg' is needed to send a request with the WebService::DataDog object"
			if !defined( $args{$arg} ) || ( $args{$arg} eq '' );
	}
	
	my $url = $args{'url'};
	my $method = $args{'method'};
	
	# Add authentication info
	if ( $url =~ /events\?/ )  #Events search endpoint will already have URL params...
	{
		$url .= '&api_key=' . $self->{'api_key'} . '&application_key=' . $self->{'application_key'};
	}
	else
	{
		$url .= '?api_key=' . $self->{'api_key'} . '&application_key=' . $self->{'application_key'};
	}
	
	my $request;
	if ( $method eq 'GET' ) ## no critic qw( ControlStructures::ProhibitCascadingIfElse )
	{
		$request = HTTP::Request->new( GET => $url );
	}
	elsif ( $method eq 'POST' )
	{
		$request = HTTP::Request->new( POST => $url );
	}
	elsif ( $method eq 'DELETE' )
	{
		$request = HTTP::Request->new( DELETE => $url );
	}
	elsif ( $method eq 'PUT' )
	{
		$request = HTTP::Request->new( PUT => $url );
	}
	else
	{
		croak ">" . $args{'command'} . "< is an unknown command. Not sending request.";
	}
	
	carp "Sending request to URL >" . ( defined( $url ) ? $url : '' ) . "< via method >$method<"
		if $verbose;
	
	
	my $json_in = JSON::encode_json( $args{'data'} );
	carp "Sending JSON request >" . ( defined( $json_in ) ? $json_in : '' ) . "<"
		if $verbose;
	
	$request->content_type('application/json');
	$request->content( $json_in );
	
	carp "Request object: ", Dumper( $request )
		if $verbose;
	
	my $user_agent = LWP::UserAgent->new();
	my $response = $user_agent->request($request);
	
	croak "Request failed:" . $response->status_line()
		if !$response->is_success();

	carp "Response >" . ( defined( $response ) ? $response->content() : '' ) . "<"
		if $verbose;

	my $json_out = JSON::decode_json( $response->content() );
	
	carp "JSON Response >" . ( defined( $json_out ) ? Dumper($json_out) : '' ) . "<"
		if $verbose;
	
	return $json_out;
}



=head1 AUTHOR

Jennifer Pinkham, C<< <jpinkham at cpan.org> >>.


=head1 BUGS

Please report any bugs or feature requests to C<bug-WebService-DataDog at rt.cpan.org>,
or through the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=WebService-DataDog>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

	perldoc WebService::DataDog


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=WebService-DataDog>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/WebService-DataDog>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/WebService-DataDog>

=item * Search CPAN

L<http://search.cpan.org/dist/WebService-DataDog/>

=back


=head1 ACKNOWLEDGEMENTS

Special thanks for architecture advice from fellow ThinkGeek CPAN author Guillaume
Aubert L<http://search.cpan.org/~aubertg/> as well as fellow ThinkGeek CPAN author
Kate Kirby L<http://search.cpan.org/~kate/>

=head1 COPYRIGHT & LICENSE

Copyright 2012 Jennifer Pinkham.

This program is free software; you can redistribute it and/or modify it
under the terms of the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut

1;

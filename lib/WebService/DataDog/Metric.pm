package WebService::DataDog::Metric;

use strict;
use warnings;

use base qw( WebService::DataDog );
use Carp qw( carp croak );



=head1 NAME

WebService::DataDog::Metric - Interface to Metric functions in DataDog's API.

=head1 VERSION

Version 0.3.1

=cut

our $VERSION = '0.3.1';


=head1 METHODS

=head2 post_metric()

Post single/multiple time-series metrics. NOTE: only metrics of type 'gauge' 
and type 'counter' are supported. You must use a dogstatsd client such as
Net::Dogstatsd to post metrics of other types (ex: 'timer', 'histogram', 'sets'
or use  increment() or decrement() on a counter). The primary advantage of the
API vs dogstatsd for posting metrics: API allows posting metrics from the past.

Per DataDog: "The metrics end-point allows you to post metrics data so it
can be graphed on Datadog's dashboards."

	my $metric = $datadog->build('Metric');
	$metric->post_metric(
		name        => $metric_name,
		type        => $metric_type,  # Optional - gauge|counter. Default=gauge.
		value       => $metric_value, # For posting a single data point, time 'now'
		data_points => $data_points,  # 1+ data points, with timestamps
		host        => $hostname,     # Optional - host that produced the metric
		tags        => $tag_list,     # Optional - tags associated with the metric
	);
	
	Examples:
	+ Submit a single point with a timestamp of `now`.
	$metric->post_metric(
		name  => 'page_views',
		value => 1000,
	);
	
	+ Submit a point with a timestamp.
	$metric->post_metric(
		name        => 'my.pair',
		data_points => [ [ 1317652676, 15 ] ],
	);
		
	+ Submit multiple points.
	$metric->post_metric(
		name        => 'my.series',
		data_points => 
		[
			[ 1317652676, 15 ],
			[ 1317652800, 16 ],
		]
	);
	
	+ Submit a point with a host and tags.
	$metric->post_metric(
		name  => 'my.series',
		value => 100,
		host  => "myhost.example.com",
		tags  => [ "version:1" ],
	);
	
	
Parameters:

=over 4

=item * name

The metric name.

=item * type

Optional. Metric type. Allowed values: gauge, counter. Default = gauge.

=item * value

Metric value. Used when you only need to post a single data point, with
timestamp 'now'. Use 'data_points' to post a single metric with a timestamp.

=item * data_points

Array of arrays of timestamp and metric value.

=item * host

Optional. Host that generated the metric.

=item * tags

Optional. List of tags associated with the metric.

=back

=cut

sub post_metric
{
	my ( $self, %args ) = @_;
	my $verbose = $self->verbose();
	
	# Perform various error checks before attempting to send metrics
	$self->_error_checks( %args );
	
	my $data = {};
	my $series = 
	{
		# Force to lowercase because DataDog is case sensitive and we don't want to
		# end up with multiple metrics of the same name, varying only in case.
		metric => lc( $args{'name'} ),
	};
	
	if ( defined $args{'type'} )
	{
		$series->{'type'} = $args{'type'};
	}
	
	if ( defined $args{'value'} )
	{
		$series->{'points'} = [ [ time(), $args{'value'} ] ];
	}
	elsif ( defined $args{'data_points'} )
	{
		$series->{'points'} = $args{'data_points'};
	}
	
	if ( defined $args{'host'} )
	{
		# Force to lowercase because DataDog is case sensitive and we don't want to
		# tag metrics with hosts of the same name, varying only in case.
		$series->{'host'} = lc( $args{'host'} );
	}
	
	if ( defined $args{'tags'} )
	{
		$series->{'tags'} = $args{'tags'};
	}
	
	$data->{'series'} = [ $series ];
	
	my $url = $WebService::DataDog::API_ENDPOINT . 'series';
	
	my $response = $self->_send_request(
		method => 'POST',
		url    => $url,
		data   => $data,
	);
	
	#TODO check that response contains "status:ok"
	
	return;
}


=head1 INTERNAL FUNCTIONS

=head2 _error_checks()

	$self->_error_checks( %args );

Common error checking for all metric types.

=cut

sub _error_checks
{
	my ( $self, %args ) = @_;
	my $verbose = $self->verbose();
	
	# Check for mandatory parameters
	foreach my $arg ( qw( name ) )
	{
		croak "ERROR - Argument '$arg' is required."
			if !defined( $args{$arg} ) || ( $args{$arg} eq '' );
	}
	
	# One of these is required
	if ( !defined $args{'value'} && !defined $args{'data_points'} )
	{
		croak "ERROR - You must specify argument 'value' for single data points, or argument 'data_points' for multiple data points";
	}
	
	# You cannot specify both
	if ( defined $args{'value'} && defined $args{'data_points'} )
	{
		croak "ERROR - You must specify argument 'value' for single data points, OR argument 'data_points' for multiple data points. Both arguments are not allowed.";
	}
	
	# Metric name starts with a letter
	if ( $args{'name'} !~ /^[a-zA-Z]/ )
	{
		croak( "ERROR - invalid metric name >" . $args{'name'} . "<. Names must start with a letter, a-z. Not sending." );
	}
	
	if ( defined $args{'value'} )
	{
		croak "ERROR - Value >" . $args{'value'} . "< is not a number."
			unless ( $args{'value'} =~ /^\d+(\.\d+)?$/ );
	}
	
	if ( defined $args{'data_points'} )
	{
		croak "ERROR - invalid value for argument 'data_points', must be an arrayref."
			unless Data::Validate::Type::is_arrayref( $args{'data_points'} );
			
		# Check that each data point is valid
		foreach my $data_point ( @{ $args{'data_points'} } )
		{
			croak "ERROR - invalid value for argument 'data_points', must be an arrayref."
				unless Data::Validate::Type::is_arrayref( $data_point );
				
			my $timestamp  = $data_point->[0];
			my $data_value = $data_point->[1];
			
			croak "ERROR - invalid timestamp >$timestamp< in data_points for >" . $args{'name'} . "<"
				unless ( $timestamp =~ /^\d{10,}$/ ); #min 10 digits, allowing for older data back to 1/1/2000
				
			croak "ERROR - invalid value >$data_value< in data_points for >" . $args{'name'} . "<. Must be a number."
				unless ( $data_value =~ /^\d+(\.\d+)?$/ );
		}
	}
	
	# Tags, if exist...
	if ( defined( $args{'tags'} ) && scalar( $args{'tags'} ) != 0 )
	{
		# is valid
		if ( !Data::Validate::Type::is_arrayref( $args{'tags'} ) )
		{
			croak "ERROR - invalid 'tag' value. Must be an arrayref.";
		}
		
		foreach my $tag ( @{ $args{'tags'} } )
		{
			# must start with a letter
			croak( "ERROR - invalid tag >" . $tag . "< on metric >" . $args{'name'} . "<. Tags must start with a letter, a-z. Not sending." )
				if ( $tag !~ /^[a-zA-Z]/ );
			
			# must be 200 characters max
			croak( "ERROR - invalid tag >" . $tag . "< on metric >" . $args{'name'} . "<. Tags must be 200 characters or less. Not sending." )
				if ( length( $tag ) > 200 );
			
			# NOTE: This check isn't required by DataDog, they will allow this through.
			# However, this tag will not behave as expected in the graphs, if we were to allow it.
			croak( "ERROR - invalid tag >" . $tag . "< on metric >" . $args{'name'} . "<. Tags should only contain a single colon (:). Not sending." )
				if ( $tag =~ /^\S+:\S+:/ );
		}
	}
	
	return;
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

	perldoc WebService::DataDog::Metric


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

Thanks to ThinkGeek (L<http://www.thinkgeek.com/>) and its corporate overlords
at Geeknet (L<http://www.geek.net/>), for footing the bill while I write code
for them!


=head1 COPYRIGHT & LICENSE

Copyright 2013 Jennifer Pinkham.

This program is free software; you can redistribute it and/or modify it
under the terms of the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut


1;

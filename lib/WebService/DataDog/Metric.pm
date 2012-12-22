package WebService::DataDog::Metric;

use strict;
use warnings;

use base qw( WebService::DataDog );
use Carp qw( carp croak );

=head1 METHODS

=head2 post_metric()

Post single/multiple time-series metrics. NOTE: only metrics of type 'gauge' 
and type 'counter' are supported. You must use a dogstatsd client such as
Net::Dogstatsd to post metrics of other types (ex: 'timer', 'histogram', 'sets'
or use  increment() or decrement() on a counter). The primary advantage of the
API vs dogstatsd for posting metrics: API allows posting metrics from the past.

Per DataDog API: "The metrics end-point allows you to post metrics data so it
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


=cut

sub post_metric
{
	my ( $self, %args ) = @_;
#	my $verbose = $self->verbose();
	
	#TODO check for required arguments
	#TODO check that 'value' or 'data_points' was specified, but not both
	#TODO check that all metric values are numbers only
	#TODO check that metric name has only allowed chars
	#TODO check that tags contain only allowed chars
	
	my $data = {};
	my $series = 
	{
		metric => $args{'name'},
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
		$series->{'host'} = $args{'host'};
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

Copyright 2012 Jennifer Pinkham.

This program is free software; you can redistribute it and/or modify it
under the terms of the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut



1;
WebService-DataDog

This module allows you to interact with DataDog (http://http://www.datadoghq.com/),
a service that will "Capture metrics and events, then graph, filter, and search
to see what's happening and how systems interact. Datadog is a service for IT,
Operations and Development teams who write and run applications at scale, and
want to turn the massive amounts of data produced by their apps, tools and
services into actionable insight."

This module encapsulates all the communications with the REST API provided by
DataDog to offer a Perl interface to metrics, dashboards, events, alerts, host
tags, etc.

You can find your API key, and generate application keys at
https://app.datadoghq.com/account/settings

For help with graph definitions (when creating/updating dashboards), please visit
http://docs.datadoghq.com/graphing/  and
http://help.datadoghq.com/kb/graphs-dashboards/graph-primer


**NOTE: This is in the development stage and has slightly reduced functionality.
I intend to continue updating, eventually adding all functionality that
DataDog-provided Ruby and Python API libraries have.

[![Build Status](https://travis-ci.org/jpinkham/webservice-datadog.png)](https://travis-ci.org/jpinkham/webservice-datadog)


Features coming soon (not necessarily in this order):

* Capture 404 errors on certain actions and show "invalid/unknown $object id" instead

* new module 'Comment'
  - create
  - edit
  - delete 

INSTALLATION

To install this module, run the following commands:

	perl Build.PL
	./Build
	./Build test
	./Build install

SUPPORT AND DOCUMENTATION

After installing, you can find documentation for this module with the
perldoc command.

    perldoc WebService::DataDog

You can also look for information at:

    RT, CPAN's request tracker (report bugs here)
        http://rt.cpan.org/NoAuth/Bugs.html?Dist=WebService-DataDog

    AnnoCPAN, Annotated CPAN documentation
        http://annocpan.org/dist/WebService-DataDog

    CPAN Ratings
        http://cpanratings.perl.org/d/WebService-DataDog

    Search CPAN
        http://search.cpan.org/dist/WebService-DataDog/


LICENSE AND COPYRIGHT

Copyright (C) 2013 Jennifer Pinkham

This program is free software; you can redistribute it and/or modify it
under the terms of the Artistic License.

See http://dev.perl.org/licenses/ for more information.


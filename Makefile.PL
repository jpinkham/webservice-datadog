require 5.006;
use ExtUtils::MakeMaker;
WriteMakefile
(
  'test' => {
              'TESTS' => 't/*.t t/Alert/*.t t/Comment/*.t t/Dashboard/*.t t/Event/*.t t/Graph/*.t t/Metric/*.t t/Search/*.t t/Tag/*.t t/User/*.t'
            },
  'PREREQ_PM' => {
                   'Carp' => 0,
                   'Class::Load' => 0,
                   'Data::Dumper' => 0,
                   'Data::Validate::Type' => '1.001000'
                   'HTTP::Request' => 0,
                   'JSON' => 0,
                   'LWP::UserAgent' => 0,
                   'Scalar::Util' => 0,
                   'Storable' => 0,
                   'Test::Exception' => 0,
                   'Test::FailWarnings' => 0,
                   'Test::Most' => 0,
                   'Try::Tiny' => 0,
                 },
  'NAME' => 'WebService::DataDog',
  'PL_FILES' => {},
  'EXE_FILES' => [],
  'INSTALLDIRS' => 'site',
  'VERSION_FROM' => 'lib/WebService/DataDog.pm'
)
;

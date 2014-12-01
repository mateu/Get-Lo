package TestES;
use Moo;
with('Get::Lo::Role::Elasticsearch');

package main;
use Test::More;
my $test = TestES->new;
ok($test->es);

done_testing();

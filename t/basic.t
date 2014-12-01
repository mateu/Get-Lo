use Get::Lo::Feed;
use Test::More;

my $feed = Get::Lo::Feed->new;
my $result = $feed->index_docs;
ok(!$result->{errors});

done_testing;

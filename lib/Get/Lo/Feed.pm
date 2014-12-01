package Get::Lo::Feed;

use utf8;
use 5.014;
use warnings;
use warnings qw( FATAL utf8 );
use open qw(:std :utf8);

use Moo;
use XML::FeedPP;
use Data::UUID;
with('Get::Lo::Role::Elasticsearch');

has feeder => (
  is => 'lazy',
  builder => sub { XML::FeedPP->new(shift->source, utf8_flag => 1) },
);
has source => (
  is => 'lazy',
  builder => sub { 'http://jobs.perl.org/rss/standard.rss?limit=50' },
);
has uuid => (
  is => 'lazy',
  builder => sub { Data::UUID->new },
);
has transformation => (
  is => 'lazy',
  builder => sub { 
    {
      description => 'description',
      title => 'title',
      'link' => 'link',
    };
  },
);

sub get_docs {
  my ($self,) = @_;

  my $docs = {};
  foreach my $item ($self->feeder->get_item()) {
    my $doc = $self->make_doc($item);
    my $uuid = $self->uuid->create_from_name_str(NameSpace_URL, $doc->{link});
    $docs->{$uuid} = $doc;
  }
  return $docs;
}

sub index_docs {
  my ($self,) = @_;

  my $docs = $self->get_docs;
  my $cos = [];
  foreach my $uuid (keys %{$docs}) {
    push @{$cos}, {'index' => 
      {
        _index => 'get_lo_test', 
        _type => 'get_lo_test', 
        _id => $uuid
      }};
      push @{$cos}, $docs->{$uuid};
  }
  
  return $self->es->bulk(body => $cos);
}

sub make_doc {
  my ($self, $doc) = @_;

my $title = 'title';
  my $transformed_doc;
  foreach my $field (keys %{$self->transformation}) {
    my $value = $self->transformation->{$field};
    $transformed_doc->{$field} = $doc->$value;
  }
  return $transformed_doc;
}

1;
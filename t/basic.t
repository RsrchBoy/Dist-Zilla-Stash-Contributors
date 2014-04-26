use strict;
use warnings;

use autobox::Core 1.24;

use Test::More;
use File::Temp 'tempdir';
use Test::DZil;

use lib 't/lib';

my @dist_ini   = qw(%Contributors FakeRelease);
my $dist_root  = tempdir CLEANUP => 1;

my $tzil = Builder->from_config(
    { dist_root => "$dist_root" },
    {
        add_files => {
            'source/dist.ini' => simple_ini(@dist_ini),
        },
    },
);

isa_ok $tzil, 'Dist::Zilla::Dist::Builder';
ok !!$tzil->stash_named('%Contributors'), 'tzil has our test plugin';

my $stash = $tzil->stash_named('%Contributors');

$stash->add_contributors(
    'Yanick Champoux <yanick@cpan.org>',
    'Ann Contributor <zann@foo.bar>',
    'Yanick Champoux <yanick@cpan.org>',
);

is_deeply [ $stash->all_contributors ], [
    'Ann Contributor <zann@foo.bar>',
    'Yanick Champoux <yanick@cpan.org>',
], "all_contributors()";

is $stash->nbr_contributors => 2, 'nbr_contributors';

my ( $cont ) = $stash->all_contributors;

isa_ok $cont => 'Dist::Zilla::Stash::Contributors::Contributor';

is $cont->name => 'Ann Contributor', "name";
is $cont->email => 'zann@foo.bar', "email";
is $cont->stringify => 'Ann Contributor <zann@foo.bar>', "stringify";

is "".$cont => 'Ann Contributor <zann@foo.bar>', "string overloading";

done_testing;

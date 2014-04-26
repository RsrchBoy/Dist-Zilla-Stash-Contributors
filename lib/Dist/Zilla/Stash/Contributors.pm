package Dist::Zilla::Stash::Contributors;
# ABSTRACT: Stash containing list of contributors

use strict;
use warnings;
use autobox::Core;

use Moose;
use namespace::autoclean;
use MooseX::AttributeShortcuts 0.023;

use aliased 'Dist::Zilla::Stash::Contributors::Contributor';

with 'Dist::Zilla::Role::Store';

has contributors => (
    traits    => [ 'Hash' ],
    isa       => 'HashRef[Dist::Zilla::Stash::Contributors::Contributor]',
    is        => 'lazy',
    predicate => -1,
    clearer   => -1,
    handles   => {
        _all_contributors => 'values',
        nbr_contributors  => 'count',
        _has_contributor  => 'exists',
        _set_contributor  => 'set',
    },
    builder => sub {
        my $self = shift @_;

        ### find all our contributors-providing plugins...
        #my @sources = $self->zilla->plugins_with('-ContributorSource');
        my %contributors =
            map { $_->email => $_ }
            map { $_->contributors }
            $self->zilla->plugins_with('-ContributorSource')->flatten
            ;
        return \%contributors;
    },
);


=method all_contributors()

Returns all contributors as C<Dist::Zilla::Stash::Contributors::Contributor>
objects. The collaborators are sorted alphabetically.

=method nbr_contributors()

Returns the number of contributors.

=cut

sub all_contributors {
    my $self = shift;

    return sort { $a->stringify cmp $b->stringify } $self->_all_contributors;
}

=method add_contributors( @contributors )

Adds the C<@contributors> to the stash. Duplicates are filtered out. 

Contributors can be L<Dist::Zilla::Stash::Contributors::Contributor> objects
or strings of the format 'Full Name <email@address.org>'.

=cut

sub add_contributors {
    my ( $self, @contributors ) = @_;

    for my $c ( @contributors ) {
        my $name = $c;
        my $email;
        $email = $1 if $name =~ s/\s*<(.*?)>\s*//;

        my $object = Contributor->new(name => $name, email => $email);

        # last in wins!
        $self->_set_contributor($email => $object);
    }

}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 SYNOPSIS


    my $contrib_stash = $self->zilla->stash_named('%Contributors');

    unless ( $contrib_stash ) {
        $contrib_stash = Dist::Zilla::Stash::Contributors->new;
        $self->_register_stash('%Contributors', $contrib_stash );
    }

$contrib_stash->add_contributors( 'Yanick Champoux <yanick@cpan.org>' );

=head1 DESCRIPTION

If you are a L<Dist::Zilla> user, avert your eyes and read no more: this
module is not for general consumption but for authors of plugins dealing 
with contributors harvesting or processing.

Oh, you're one of those? Excellent. Well, here's the deal: this is a 
stash that is meant to carry the contributors' information between plugins.
Plugins that gather contributors can populate the list with code looking like
this:

    sub before_build {
        my $self = shift;

        ...; # gather @collaborators, somehow

        my $contrib_stash = $self->zilla->stash_named('%Contributors');
        unless ( $contrib_stash ) {
            $contrib_stash = Dist::Zilla::Stash::Contributors->new;
            $self->_register_stash('%Contributors', $contrib_stash );
        }

        $contrib_stash->add_contributors( @contributors );
    }
    

and plugin that use them:

        # of course, make sure this is run *after* the gatherers did their job
    sub before_build {
        my $self = shift;

        my $contrib_stash = $self->zilla->stash_named('%Contributors')
            or return;

        my @contributors = $contrib_stash->all_contributors;
    }
    

And that's pretty much all you need to know beside that, internally, each contributor is represented by 
a L<Dist::Zilla::Stash::Contributors::Contributor> object.

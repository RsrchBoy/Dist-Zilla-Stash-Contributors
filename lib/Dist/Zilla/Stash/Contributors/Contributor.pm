package Dist::Zilla::Stash::Contributors::Contributor;
# ABSTRACT: a Contributors stash element

use strict;
use warnings;

use Moose;
use MooseX::MarkAsMethods -autoclean => 1;

use overload
    '""' => \&stringify,
    '==' => sub { shift->equivalent_to(@_) },
    ;

=method new( name => $name, email => $address )

Creates a new C<Dist::Zilla::Stash::Contributors::Contributor> object. 

=back

=cut

=method name()

Returns the name of the contributor.

=cut

has name => (
    isa => 'Str',
    is => 'ro',
    required => 1,
);

=method email()

Returns the email address of the contributor.

=cut

has email => (
    is => 'ro',
    isa => 'Str',
    required => 1,
);

=method stringify()

Returns the canonical string for the collaborator, of the form 
"Full Name <email@address.org>".

The object will automatically call this function is used
as a string. 

    say $_ for $stash->all_contributors;

=cut

sub stringify { sprintf '%s <%s>', $_[0]->name, $_[0]->email }

=method equivalent_to($other_contrib)

Given another Contributor object, we determine if we're equivalent by checking
to see if we stringify to the same value.

=cut

sub equivalent_to { shift->stringify eq shift->stringify }

__PACKAGE__->meta->make_immutable;
1;

=head1 SYNOPSIS

    if( my $contrib_stash = $self->zilla->stash_named('%Contributors') ) {
        my @collaborators = sort { $a->email cmp $b->email } 
            $contrib_stash->all_contributors;

        $self->log( "contributor: " . $_->stringify ) for @collaborators;
    }

=head1 DESCRIPTION

Collaborator objects used in the L<Dist::Zilla::Stash::Contributors> stash.


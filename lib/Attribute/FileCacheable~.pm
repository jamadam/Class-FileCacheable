package Attribute::FileCacheable;

use strict;
use warnings;

our $VERSION = '0.01';

sub new {
    my $class = shift;
    my $self  = bless {}, $class;

    $self;
}

1;

__END__

=head1 NAME

Attribute::FileCacheable - 

=head1 SYNOPSIS

    use Attribute::FileCacheable;
    Attribute::FileCacheable->new;

=head1 DESCRIPTION

=head1 METHODS

=head2 new

=head1 AUTHOR

Sugama Keita, E<lt>sugama@jamadam.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Sugama Keita.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut

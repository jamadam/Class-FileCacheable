package Class::FileCacheable;
use strict;
use warnings;
use Attribute::Handlers;
use Data::Dumper;
use 5.005;
our $VERSION = '0.02';
	
	my %fnames;
	my %cf_obj;
	my %cache_opt;
	
	### ---
	### return true if cache *EXPIRED*
	### ---
	sub file_cache_expire {
		return 0;
	}
	
	### ---
	### Define FileCacheable attribute
	### ---
	sub FileCacheable : ATTR(CHECK) {
		
		#my($pkg, $sym, $ref, $attr, $data, $phase) = @_;
		my($pkg, $sym, $ref, undef, $data, undef) = @_;
		
		no warnings 'redefine';
		
		*{$sym} = sub {
			my $self = shift;
			$cache_opt{$pkg} ||= $self->file_cache_options;
			$cf_obj{$pkg} ||=
				new Class::FileCacheable::_CF($cache_opt{$pkg});
			my $cache_id_seed =
			$data->[0]->{default_key} || $cache_opt{$pkg}->{default_key} || '';
			my $cache_id = *{$sym}. "\t". $cache_id_seed;
			if ($cache_opt{$pkg}->{number_cache_id}) {
				$cache_id .= "\t" . ($fnames{*{$sym}}++);
			}
			
			my $output;
			my $cache_tp = $cf_obj{$pkg}->get_cache_timestamp($cache_id);
			
			### check expire
			if (defined $cache_tp) {
				if ($data->[0]->{expire_ref}) {
					if (! $data->[0]->{expire_ref}->($cache_tp)) {
						$output = $cf_obj{$pkg}->get($cache_id);
					}
				} elsif (! $self->file_cache_expire($cache_tp)) {
					$output = $cf_obj{$pkg}->get($cache_id);
				}
			}
			
			### generate cache
			if (! defined($output)) {
				no strict 'refs';
				$output = $self->$ref(@_);
				$cf_obj{$pkg}->set($cache_id, $output);
			}
			
			return $output;
		}
	}
	
	DESTROY {
		shift->file_cache_purge();
	}
	
	sub file_cache_purge {
		
	}

package Class::FileCacheable::_CF;
use strict;
use warnings;
use Data::Dumper;
use base qw(Cache::FileCache);
	
	sub get_cache_timestamp {
		
		my ($self, $id) = @_;
		return
			(stat $self->{_Backend}->_path_to_key($self->{_Namespace}, $id))[9];
	}

1;

__END__

=head1 NAME

Class::FileCacheable - DEVELOPING

=head1 SYNOPSIS

    use base 'Class::FileCacheable';
	
	sub file_cache_expire {
		my ($self, $timestamp) = @_;
		if (some_condifion) {
			return 1;
		}
	}
	
	sub file_cache_options {
		return {
			'namespace' => 'MyNamespace',
			'cache_root' => 't/cache',
			#...
		};
	}
	
	sub some_sub1 : FileCacheable {
		
		my $self = shift;
	}
	
	sub some_sub2 : FileCacheable(\&expire_code_ref) {
		
		my $self = shift;
	}

=head1 DESCRIPTION

This module defines an attribute "FileCacheable" which redefines your functions
cacheable. This module depends on L<Cache::FileCache> for managing cache files.

To use this, do following steps.

=item use base 'Class::FileCacheable';

=item override the method I<file_cache_expire>

=item override the method I<file_cache_option>

=item define your subs as follows

	sub your_sub : FileCacheable {
		my $self = shift;
		# do something
	}

That's it.

=head1 METHODS

=head2 file_cache_expire

This is a callback method for specifying the condition for cache expiretion.
Your module can override the method if necessary.

file_cache_exipre will be called as instance method when the target method
called. This method takes timestamp of the cache as argument.

	sub file_cache_expire {
		my ($self, $timestamp) = @_;
		if (some_condifion) {
			return 1;
		}
	}

file_cache_exipre should return 1 or 0. 1 causes the cache *EXPIRED*

=head2 file_cache_options

This is a callback method for specifying L<Cache::FileCache> options. Your
module can override the method if necessary.

    sub file_cache_options {
        return {
            'namespace' => 'Test',
            'cache_root' => 't/cache',
        };
    }

In addition to L<Cache::FileCache> options, you can set extra options bellow

=item number_cache_id

This takes 1 or 0 for value. '1' causes the cache ids automatically numbered so
the caches doesn't affect in single process. This is useful if you want to
cache the function calls as a sequence.

=head2 file_cache_purge

Not implemented yet

=head1 EXAMPLE

    package GetExampleDotCom;
    use strict;
    use warnings;
    use base 'Class::FileCacheable';
    use LWP::Simple;
    
        sub new {
            return bless {}, shift;
        }
        
        sub get : FileCacheable {
            my $self = shift;
            return get("http://example.com/");
        }
    
        sub file_cache_expire {
            my ($self, $timestamp) = @_;
            if (time() - $timestamp > 86400) {
                return 1;
            }
        }
        
        sub file_cache_options {
            return {
                'namespace' => 'GetRemoteFile',
                'cache_root' => './cache',
            };
        }

=head1 SEE ALSO

L<Cache::FileCache>

=head1 AUTHOR

Sugama Keita, E<lt>sugama@jamadam.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Sugama Keita.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut

package Attribute::FileCacheable;
use strict;
use warnings;
use Attribute::Handlers;
use Data::Dumper;
use 5.005;
our $VERSION = '0.02';
	
	### ---
	### Cachable attribute
	### ---
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
		
		my($pkg, $sym, $ref, $attr, $data, $phase) = @_;
		
		no warnings 'redefine';
		
		*{$sym} = sub {
			$cache_opt{$pkg} ||= $pkg->file_cache_options;
			$cf_obj{$pkg} ||=
				new Attribute::FileCacheable::_CF($cache_opt{$pkg});
			my $cache_num = $fnames{*{$sym}}++;
			my $cache_id =
			join("\t", *{$sym}, $cache_num,
			$data->[0]->{default_key} || $cache_opt{$pkg}->{default_key} || '');
			my $output;
			
			my $cache_tp = $cf_obj{$pkg}->get_cache_timestamp($cache_id);
			
			### check expire
			if (defined $cache_tp) {
				if ($data->[0]->{expire_ref}) {
					if (! $data->[0]->{expire_ref}->($cache_tp)) {
						$output = $cf_obj{$pkg}->get($cache_id);
					}
				} elsif (! $pkg->file_cache_expire($cache_tp)) {
					$output = $cf_obj{$pkg}->get($cache_id);
				}
			}
			
			### generate cache
			if (! defined($output)) {
				no strict 'refs';
				$output = $ref->(@_);
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
	
	sub debugPrint {
		my $dump = Dumper($_[0]); $dump =~ s/\\x{([0-9a-z]+)}/chr(hex($1))/ge;
		return $dump;
	}

package Attribute::FileCacheable::_CF;
use strict;
use warnings;
use Data::Dumper;
use base qw(Cache::FileCache);
	
	sub get_cache_timestamp {
		
		my ($self, $id) = @_;
		return
			(stat $self->{_Backend}->_path_to_key($self->{_Namespace}, $id))[9];
	}
	
	### --------------
	### デバッグ出力
	### --------------
	sub debugPrint {
		
		my $dump = Dumper($_[0]); $dump =~ s/\\x{([0-9a-z]+)}/chr(hex($1))/ge;
		return $dump;
	}

1;

__END__

=head1 NAME

Attribute::FileCacheable - DEVELOPING

=head1 SYNOPSIS

    use base 'Attribute::FileCacheable';
	
	sub file_cache_expire {
		if ($to_old) {
			return 1;
		}
		return;
	}
	
	sub file_cache_options {
		return {
			'namespace' => 'MyNamespace',
			'cache_root' => 't/cache',
			#...
		};
	}
	
	sub some_sub1 : FileCacheable {
		
	}
	
	sub some_sub2 : FileCacheable(\&expire_code_ref) {
		
	}

=head1 DESCRIPTION

This module defines a attribute "FileCacheable" which redefines your functions
cacheable.

=head1 METHODS

=head2 new

=head1 AUTHOR

Sugama Keita, E<lt>sugama@jamadam.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Sugama Keita.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut

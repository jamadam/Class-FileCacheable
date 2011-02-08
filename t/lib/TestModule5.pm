package TestModule2;
use strict;
use warnings;
use base 'Attribute::FileCacheable';

	sub sub1 : FileCacheable {
		
		my $arg = shift;
		return $arg;
	}
	
	sub file_cache_expire {
		
		return 0;
	}
	
	sub file_cache_options {
		
		return {
			'namespace' => 'TestModule2',
			'cache_root' => 't/cache',
			'avoid_share_cache_in_process' => 0,
		};
	}

1;

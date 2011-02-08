package TestModule;
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
			'namespace' => 'Test',
			'cache_root' => 't/cache',
		};
	}

1;

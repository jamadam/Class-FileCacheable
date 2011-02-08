package TestModule2;
use strict;
use warnings;
use base 'Attribute::FileCacheable';

    sub sub1 : FileCacheable {
        return shift;
    }
    
    sub file_cache_expire {
        return 0;
    }
    
    sub file_cache_options {
        return {
            'namespace' => 'Test',
            'cache_root' => 't/cache',
            'avoid_share_cache_in_process' => 1,
        };
    }

1;

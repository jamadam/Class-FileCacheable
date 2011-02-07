package main;
use strict;
use warnings;
use lib 't/lib', 'lib';
use Test::More;
use base qw(
    Test::Class
    Attribute::FileCacheable
);

__PACKAGE__->runtests;

sub basic1 : Test(2) {
    
    if (-d 't/cache/MyNamespace') {
        unlink('t/cache/MyNamespace');
    }
    is(sub1('test'), 'test');
	warn '===3';
    is(sub1('test2'), 'test');
}

sub sub1 : FileCacheable {
    
	warn '===4';
    my $arg = shift;
    return $arg;
}

sub file_cache_expire {
    
    return 0;
}

sub file_cache_options {
    
    return {
        'namespace' => 'MyNamespace',
        'cache_root' => 't/cache',
    };
}
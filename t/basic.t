package main;
use strict;
use warnings;
use lib 't/lib', 'lib';
use Test::More;
use base 'Test::Class';
use TestModule;
use TestModule2;
use File::Path;
    
    my $cache_namespace_base = 't/cache/Test';
    
    __PACKAGE__->runtests;
    
    sub basic1 : Test(2) {
        
        if (-d $cache_namespace_base) {
            rmtree($cache_namespace_base);
        }
        is(TestModule::sub1('test'), 'test');
        is(TestModule::sub1('test2'), 'test');
    }
    
    sub basic2 : Test(3) {
        
        if (-d $cache_namespace_base) {
            rmtree($cache_namespace_base);
        }
        is(TestModule2::sub1('test'), 'test');
        is(TestModule2::sub1('test2'), 'test2');
        
        if (-d $cache_namespace_base) {
            rmtree($cache_namespace_base);
        }
        is(TestModule2::sub1('test2'), 'test2');
    }
    
    END {
        if (-d $cache_namespace_base) {
            rmtree($cache_namespace_base);
        }
    }
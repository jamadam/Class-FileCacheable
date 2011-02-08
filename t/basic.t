package main;
use strict;
use warnings;
use lib 't/lib', 'lib';
use Test::More;
use base 'Test::Class';
use TestModule;
use TestModule2;
use TestModule3;
use TestModule4;
use File::Path;
    
    my $cache_namespace_base = 't/cache/Test';
    
    __PACKAGE__->runtests;
    
    sub basic1 : Test(2) {
        
        if (-d $cache_namespace_base) {
            rmtree($cache_namespace_base);
        }
        is(TestModule::sub1('test'), 'test'); # must be cached
        is(TestModule::sub1('test2'), 'test');
    }
    
    sub basic2 : Test(3) {
        
        if (-d $cache_namespace_base) {
            rmtree($cache_namespace_base);
        }
        is(TestModule2::sub1('test'), 'test'); # must be cached
        is(TestModule2::sub1('test2'), 'test2'); # must be cached
        
        if (-d $cache_namespace_base) {
            rmtree($cache_namespace_base);
        }
        is(TestModule2::sub1('test2'), 'test2');
    }
    
    sub oop_basic : Test(10) {
        
        if (-d $cache_namespace_base) {
            rmtree($cache_namespace_base);
        }
        
        is(TestModule3->get_class, 'TestModule3'); # must be cached
        is(TestModule3->get_class, 'TestModule3');
        
        is(TestModule3->sub1('test'), 'test'); # must be cached
        is(TestModule3->sub1('test2'), 'test');
        
        my $instance = TestModule3->new;
        like($instance->get_instance, qr{^TestModule3}); # must be cached
        like($instance->get_instance, qr{^TestModule3});
        
        if (-d $cache_namespace_base) {
            rmtree($cache_namespace_base);
        }
        
        is($instance->sub1('test'), 'test'); # must be cached
        is($instance->sub1('test2'), 'test');
        
        if (-d $cache_namespace_base) {
            rmtree($cache_namespace_base);
        }
        
        is(TestModule3->sub1('test'), 'test'); # must be cached
        is($instance->sub1('test2'), 'test');
    }
    
    sub file_cache_expire_gets_timestamp : Test(3) {
        
        if (-d $cache_namespace_base) {
            rmtree($cache_namespace_base);
        }
        
        is(TestModule4->get_debug_timestamp, undef);
        my $a = TestModule4->new();
        $a->sub1('test');
        is(TestModule4->get_debug_timestamp, undef);
        $a->sub1('test');
        isnt(TestModule4->get_debug_timestamp, undef);
    }
    
    sub specify_expire_ref : Test(3) {
        
        if (-d $cache_namespace_base) {
            rmtree($cache_namespace_base);
        }
        
        my $a = TestModule4->new();
        is($a->sub2('sub2-1'), 'sub2-1');
        is($a->sub2('sub2-2'), 'sub2-2');
    }
    
    END {
        if (-d $cache_namespace_base) {
            rmtree($cache_namespace_base);
        }
    }
    
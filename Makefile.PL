use inc::Module::Install;
name 'Class-VirtualAccessor';
all_from 'lib/Class/VirtualAccessor.pm';
readme_from 'lib/Class/VirtualAccessor.pm';
readme_pod_from 'lib/Class/VirtualAccessor.pm';
githubmeta;

# requires '';

tests 't/*.t';
author_tests 'xt';

build_requires 'Test::More';
auto_set_repository;
auto_include;
WriteAll;

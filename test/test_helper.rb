TEST_ROOT = File.join(File.dirname(__FILE__), '..')
$LOAD_PATH << File.join(TEST_ROOT, 'lib')
$LOAD_PATH << File.join(TEST_ROOT, 'lib', 'dtaus')

require 'test/unit'
require 'dtaus'

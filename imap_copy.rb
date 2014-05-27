#! /usr/bin/env ruby

require 'net/imap'
require 'optparse'
require 'highline/import'


SLICE = 200
host1 = 'localhost'
host2 = '192.168.200.1'
path = ''
password = nil
all_flags = true

STDOUT.sync = true

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: #{$0} [options] <username>"

  opts.on("--host1 HOST") do |h|
    host1 = h
  end

  opts.on("--host2 HOST") do |h|
    host2 = h
  end

  opts.on("--folder FOLDER") do |folder|
    path = folder
  end

  opts.on("--password PASSWORD") do |pass|
    password = pass
  end

  opts.on("--unseen") do
    all_flags = false
  end
end.parse!


if ARGV.length < 1 
  puts "#{$0} [option] <username>"
  exit 1
end 
username = ARGV[0]

$0 = "imap_copy_#{username}"

unless password
  password = ask("Enter password: ") { |q| q.echo = false }
end

imap1 = Net::IMAP.new(host1)
imap2 = Net::IMAP.new(host2)

auth_type = 'LOGIN'

imap1.authenticate(auth_type, username, password)
imap2.authenticate(auth_type, username, password)

puts "Authenticate IMAP Success"

folder = (path.empty?) ? imap1.list("", "%").collect { |x| x.name } : [ path ]
search_opt = all_flags ? 'all' : 'or ANSWERED or FLAGGED or Draft or UNSEEN or KEYWORD $JUNK or KEYWORD $FORWARDED KEYWORD $NotJunk'

folder.each do |mbox|

  puts "===  Start Copy flag from #{mbox} ==="
  imap1.select mbox
  imap2.select mbox

  src_list = imap1.search search_opt
  next if src_list.length <= 0 
  src_list.each_slice(SLICE).to_a.each do |list|
    elements = imap1.fetch(list, '(BODY.PEEK[HEADER.FIELDS (MESSAGE-ID)] FLAGS)')
    elements.each do | entry |
      attrs = entry.attr
      message_id = attrs['BODY[HEADER.FIELDS (MESSAGE-ID)]'].gsub(/Message-Id:/i,'').strip
      flags = attrs['FLAGS']

      message2 = imap2.search "HEADER MESSAGE-ID #{message_id}"
      if message2.length > 0 
      	attrs2 = imap2.fetch(message2, 'FLAGS')[0].attr
	  	flags2 = attrs['FLAGS'] - [:Recent]
        puts "#{message_id} #{flags} ==> #{message2} (#{attrs2['FLAGS']})}"
      	imap2.store message2, 'FLAGS', flags
      end
    end
  end
end

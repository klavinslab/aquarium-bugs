#!/usr/bin/env ruby

# from: https://gist.github.com/badboy/5817044

#
# A quick script to dump an overview of all the open issues in all my github projects
#

require 'fileutils'
require 'octokit'
require 'awesome_print'
require 'rainbow'

access_token = ENV['GITHUB_TOKEN']

client      = Octokit::Client.new( access_token: access_token )
key_width   = 15
label_color = Hash.new( :cyan )

label_color['bug']     = :red
label_color['feature'] = :green
label_color['todo']    = :blue

repo = client.repository({
  user: ENV['GITHUB_USER'],
  repo: ENV['GITHUB_REPO']
})

print Rainbow("Repository : ").rjust( key_width ).foreground( :green ).bright
puts  repo.name
FileUtils.mkdir_p("issues/#{repo.name}") unless File.exist? "issues/#{repo.name}"

#print "Issue Count : ".rjust( key_width ).foreground( :yellow ).bright
puts  repo.open_issues

# TODO: this method gets issues in pages of length 30
issues = client.issues(repo.full_name, page:1)
puts issues.length

issues.each do |issue|
  puts issue
  print Rainbow("%3d : " % issue.number).rjust( key_width).foreground( :white ).bright
  labels = []
  unless issue.labels.empty?
    issue.labels.each do |l|
      labels << Rainbow(l.name).foreground( label_color[l] ).bright
    end
  end
  # print labels.join(' ') + " "
  puts issue.title
  path = "issues/#{repo.name}/issue-#{issue.number}.txt"
  unless File.exist? path
    File.open(path, "w") do |f|
      comments = client.issue_comments(repo.full_name, issue.number)
      f.puts "\##{issue.number} #{issue.title}"
      f.puts "By #{issue.user.login} on #{issue.created_at}"
      f.puts "Labels: #{issue.labels.join(" ")}" unless issue.labels.empty?
      f.puts
      f.puts issue.body
      f.puts
      f.puts "Comments: #{comments.size}"
      comments.each do |comment|
        f.puts "--------"
        f.puts "From #{comment.user.login} on #{comment.created_at}"
        f.puts
        f.puts comment.body
        f.puts
      end
    end
  end
end
puts

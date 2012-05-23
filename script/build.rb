#!/usr/bin/env ruby

def build
  system('grep hogehoge README')
end


require 'github_pulls'

api = GithubPulls::API.new('holysugar/sandbox')

pulls = api.pulls

puts "#{pulls.count} pull request(s)"
exit if pulls.empty?

pulls.each do |pull|
  comments = api.comments(pull.number)
  unless comments.any?{|c| c.body.include?("Build #{pull.sha}") }
    `#{pull.fetch_and_merge_command}`
    #FIXME api call to comment
    if build
      puts "Jenkins says it's ok! :"
      puts "Build #{pull.sha} was succeeded in #{ENV['BUILD_URL']}"
      exit true
    else
      puts "Jenkins falls..."
      puts "Build #{pull.sha} was failed in #{ENV['BUILD_URL']}"
      exit false
    end
  end
end

puts "Nothing to do."
exit


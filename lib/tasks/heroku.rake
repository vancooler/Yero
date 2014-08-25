namespace :heroku do
  task :keep_awake do
    # this script it to keep the heroku server alive because it keeps on shutting down to save
    # heroku money on the free accounts.

    Thread.new do
      while line = STDIN.gets
        if line.chomp == 'x'
          wake_up_the_octopus
        end
      end
    end

    loop do
      random_wait
      wake_up_the_octopus
    end
  end


  def random_wait
    # wait between 10 to 59 minutes
    puts "waiting for #{seconds = (60..3540).to_a.sample} seconds. Press x, enter to wake up the octopus now."
    sleep seconds
  end

  def wake_up_the_octopus
    #send a get request to the home page
    t1 = Time.now
    response = RestClient.get 'http://purpleoctopus-staging.herokuapp.com'
    t2 = Time.now
    puts "#{Time.now} - #{response.code} - Purple Octopus woke up in #{(t2-t1).round(2)} seconds!"
  end

end
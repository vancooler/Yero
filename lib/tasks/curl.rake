namespace :curl do
# http://purpleoctopus-staging.herokuapp.com/api/users/signup

  email= "#{rand(36**8).to_s(36)}@example.com"
  gender=["M","F"].sample
  birthday = (Date.today - 20.years).to_s
  first_name = "#{rand(36**5).to_s(36)}"
  base_url = 'http://920eb6d.ngrok.com'
  base_url = 'http://localhost:3000/'
  signup_url = base_url+'/api/users/signup'


  task :new_user do
    system_run('curl -v -H "Content-Type: application/json" -H "Accept: application/json" -X POST -d "{\"user\":{\"email\":\"'+email+'\",\"first_name\":\"'+first_name+'\",\"birthday\":\"'+birthday+'\",\"gender\":\"'+gender+'\"}}" '+signup_url)
  end

  # task new_user_with_avatar: :environment do 
  #   avatar_path = '/home/alex/sites/yero/purpleoctopus-staging/lib/tasks/sample_avatar.jpg'
  #   system_run('curl -v -H "Content-Type: application/json" -H "Accept: application/json" -X POST -d "{\"user\":{\"email\":\"'+email+'\",\"first_name\":\"'+first_name+'\",\"birthday\":\"'+birthday+'\",\"gender\":\"'+gender+'\{\"user_avatars_attributes\":{\"avatar"\:@'+avatar_path+'}}"}}" http://localhost:3000/api/users/signup')
  #   # curl -d "userid=1&filecomment=This is an image file" --data-binary @"/home/user1/Desktop/test.jpg" localhost/uploader.php

  # end

  task new_user_with_avatar: :environment do 
    avatar_path = '/home/alex/sites/yero/purpleoctopus-staging/lib/tasks/sample_avatar.jpg'
     p response = RestClient.post( signup_url,
                        {
                          :user => {
                            :first_name => 'Alex',
                            :gender => 'M',
                            :birthday => Date.today - 20.years,
                            :user_avatars_attributes =>{
                              "0"=> {:avatar=> File.new(avatar_path, 'rb')}
                            }
                          }
                        }
                      )
  end

  def system_run(command)
    system("echo running:")
    system("echo #{command}")
    system("echo output:")
    system("#{command}")
    system("echo \n")
  end
end
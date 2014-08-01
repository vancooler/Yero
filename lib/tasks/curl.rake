namespace :curl do

  task :new_user do
    email= "#{rand(36**8).to_s(36)}@example.com"
    gender=["M","F"].sample
    birthday = (Date.today - 20.years).to_s
    first_name = "#{rand(36**5).to_s(36)}"
    system_run('curl -v -H "Content-Type: application/json" -H "Accept: application/json" -X POST -d "{\"user\":{\"email\":\"'+email+'\",\"first_name\":\"'+first_name+'\",\"birthday\":\"'+birthday+'\",\"gender\":\"'+gender+'\"}}" http://localhost:3000/api/users/signup')
  end

  def system_run(command)
    system("echo running:")
    system("echo #{command}")
    system("echo output:")
    system("#{command}")
    system("echo \n")
  end
end
class FutureCollege< ActiveRecord::Base

  def self.unique_enter(name, user)
  	whitelist = ["university", "college", "institute"]
  	is_college = false
  	whitelist.each do |keyword|
  		if name.downcase.include? keyword
  			is_college = true
  		end
  	end
  	if is_college
	    college = FutureCollege.find_by_name(name)
	    if college.nil? 
	      FutureCollege.create(name: name, unique_count: 1, user_ids: ";"+user.id.to_s+";")
	    else
	      if (college.user_ids.include? ";"+user.id.to_s+";")
	      else
		      college.update(unique_count: college.unique_count+1, user_ids: college.user_ids+user.id.to_s+";")
		  end
	    end
	end
  end

end
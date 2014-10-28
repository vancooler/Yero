module ApplicationHelper

	# returns active page
	def check_active(url)
		return current_page?(url) ? ' active': ''
	end

	# returns body class, defined on individual view
	def body_class(class_name="page")
    content_for :body_class, class_name
  end
end

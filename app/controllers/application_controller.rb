class ApplicationController < ActionController::Base
  before_action :protect_against_fake_py_header

	def after_sign_out_path_for(resource_or_scope)
    root_path
	end

  private
  def protect_against_fake_py_header
    Warden::PpyAuthStrategy.remove_py_header_if_not_valid(request)
  end
end
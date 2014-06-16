module CustomFilters
  extend ActiveSupport::Concern
  include Shibbolite::Filters

  included do
    helper_method :user_has_matching_attribute?
  end
  protected

  def require_attribute(attr, value)
    unless user_has_matching_attribute?(attr, value)
       redirect_to login_or_access_denied
     end
  end

  def require_group_or_attribute(*groups, attr, value)
    unless user_has_matching_attribute?(attr, value)
      require_group(groups)
    end
  end

  # since current_user won't be populated for regular users
  #  this method matches against the raw environment variables
  #  instead of the database attributes
  def user_has_matching_attribute?(attr, value)
    request.env[attr.to_s] == value
  end
end
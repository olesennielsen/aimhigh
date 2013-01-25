module ApplicationHelper

  # Returns the full title on a per-page basis.
  def full_title(page_title)
    base_title = "Aimhigh"
    if page_title.empty?
      base_title
    else
      "#{base_title} | #{page_title}"
    end
  end

  def current_auth_resource
    if admin_signed_in?
      current_admin
    else
      current_athlete
    end
  end

  def current_ability
    @current_ability or @current_ability = Ability.new(current_auth_resource)
  end
end



module ApplicationHelper
  def nav_item(title, controller, action = 'index')
    is_current_controller = controller == params[:controller]
    is_current_action = action == params[:action]
    is_current = is_current_controller && is_current_action

    target = is_current ? '#' : url_for(controller: controller, action: action)

    content_tag(:li, class: 'nav-item' + (is_current_controller ? ' active' : '')) do
      link_to(target, class: 'nav-link') do
        concat title
        concat content_tag(:span, '(current)', class: 'sr-only') if is_current
      end
    end
  end
end

module ApplicationHelper
  include Pagy::Frontend

  def app_name
    'Employee Tracker'
  end

  def nav_business_name
    current_business ? current_business.name : app_name
  end
  
  def default_icon_link_color
    'dimgrey'
  end

  def select_left_link(path, color: default_icon_link_color)
    link_to mdi_svg('hand-pointing-left', style: "fill:#{color};"), path
  end
  
  def select_right_link(path, color: default_icon_link_color)
    link_to mdi_svg('hand-pointing-right', style: "fill:#{color};"), path
  end
  
  def edit_link(path, color: default_icon_link_color)
    link_to mdi_svg('pencil-outline', style: "fill:#{color};"), path
  end

  def delete_link(path, color: default_icon_link_color, confirm: true, confirm_message: 'Are you sure?')
    link_to mdi_svg('trash-can-outline', style: "fill:#{color};"), path, 
      method: :delete, 
      data:   confirm == true ? { confirm: confirm_message } : {}
  end

  def show_action?
    action_name == 'show'
  end
  
  def output_field(label: '', value:)
    "<div class=\"form-group row string required user_email\">
      <div class=\"col-sm-3 col-form-label\">#{label}</div>
      <div class=\"col-sm-9\">
        <div class=\"form-control output-field\" id=\"user_email\">#{value}</div>
      </div>
    </div>".html_safe
  end
end

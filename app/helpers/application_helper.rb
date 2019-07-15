module ApplicationHelper
  def edit_link(path)
    link_to mdi_svg("pencil-outline"), path
  end

  def delete_link(path, confirm: true)
    data = confirm == true ? { confirm: 'Are you sure?' } : {}
    link_to mdi_svg('trash-can-outline'), path, method: :delete, data: data
  end

  def show_action?
    action_name == 'show'
  end
end

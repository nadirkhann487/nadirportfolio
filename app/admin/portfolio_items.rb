ActiveAdmin.register PortfolioItem do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :name, :language, :category, :description, :client
  #
  # or
  #
  # permit_params do
  #   permitted = [:name, :language, :category, :description, :client]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  
      permit_params :name,:description,:category,:language,:client,:URL,:image

end

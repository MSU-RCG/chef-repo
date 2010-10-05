require "pp"

define :rcg_user do
  pp params
  useritem = data_bag_item("users",params[:name])
  pp useritem
end
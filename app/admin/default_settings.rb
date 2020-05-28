ActiveAdmin.register DefaultSetting do
  permit_params :title, :description

  form do |f|
    f.semantic_errors *f.object.errors.keys

    f.inputs do
      f.input :title
      f.input :description
    end

    f.actions
  end
end



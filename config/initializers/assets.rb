# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = "1.0"

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path
# Add Yarn node_modules folder to the asset load path.
Rails.application.config.assets.paths << Rails.root.join("node_modules")

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
Rails.application.config.assets.precompile += %w( 
  landing/bootstrap.min.css
  landing/owl.carousel.css
  landing/slicknav.min.css
  landing/icofont.css
  landing/lightbox.min.css
  landing/animate.min.css
  landing/style.css
  landing/style-1.css
  landing/responsive-1.css
  landing/jquery.min.js
  landing/bootstrap.min.js
  landing/jquery.slicknav.min.js
  landing/owl.carousel.min.js
  landing/jquery.easypiechart.min.js
  landing/lightbox.min.js
  landing/wow-1.3.0.min.js
  landing/common.js
  landing/main-1.js
)

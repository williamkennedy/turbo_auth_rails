class Turbo::Ios::PathConfigurationsController < ApplicationController
  skip_before_action :authenticate
  # Defines the tabs and rules for the mobile app views
  # To customize this, you can edit the JSON here
  def show
    render json: {
      rules: [
        {
          patterns: ["/new$", "/edit$"],
          properties: {
            presentation: "modal"
          }
        },
        {
          patterns: ["/sign_in$"],
          properties: {
            presentation: 'authentication'
          }
        }
      ]
    }
  end
end

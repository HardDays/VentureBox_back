module RailsAdmin::User
  extend ActiveSupport::Concern

  included do
    rails_admin do
      exclude_fields :access_token, :refresh_token, :google_calendar_id, :espo_user_id

      list do
        exclude_fields :password, :is_email_notifications_available, :interesting_companies,
                       :invested_companies, :company, :goals, :updated_at, :created_at, :phone
      end
      update do
        exclude_fields :password
      end
    end
  end
end
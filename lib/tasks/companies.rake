namespace :companies do
  desc "Delete companies without image"
  task delete_invalid_companies: :environment do
    companies = Company.all
    print(companies.count)

    companies.each do |company|
      unless company.company_image
        company.user.destroy
        print "."
      end
    end
  end

end

namespace :countries do
  desc "Fullfill the countries model"
  task fullfill_countries: :environment do
    countries_json = JSON.parse(File.read('countries.json'))

    countries_json.each do |country|
      Country.create!(
        name: country["name"],
        code: country["code"]
      )
      print "."
    end
  end

end

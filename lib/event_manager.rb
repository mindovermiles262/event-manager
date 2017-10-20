require 'csv'
require 'google/apis/civicinfo_v2'


def clean_zipcode(zipcode)
  if zipcode.nil?
    "00000"
  elsif zipcode.length < 5
    zipcode.rjust(5,"0")
  elsif zipcode.length > 5
    zipcode[0..4]
  else
    zipcode
  end
end

def legislators_by_zip_code(zip)
  return if zip == "00000"
  puts "Zip: #{zip}"
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'
  legislators = civic_info.representative_info_by_address(
                              address: zip, 
                              levels: 'country', 
                              roles: ['legislatorUpperBody', 'legislatorLowerBody'])
  
  legislator_names = legislators.officials.map{ |legislator| legislator.name }
  
  legislator_names.join(", ")
end

puts "EventManager initialized."

contents = CSV.open 'event_attendees.csv', headers: true, header_converters: :symbol

contents.each do |row|
  name = row[:first_name]

  zipcode = clean_zipcode(row[:zipcode])

  legislators = legislators_by_zip_code(zipcode)

  puts "#{name} #{zipcode} #{legislators}"
end
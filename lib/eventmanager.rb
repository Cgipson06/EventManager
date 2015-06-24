require 'csv'
require 'sunlight/congress'
require 'erb'
require 'date'

Sunlight::Congress.api_key = "e179a6973728c4dd3fb1204283aaccb5"

def clean_zipcode(zipcode) 
  zipcode.to_s.rjust(5,"0")[0..4]
end

def legislators_by_zipcode(zipcode)
  Sunlight::Congress::Legislator.by_zipcode(zipcode)
end

def save_thank_you_letters(id, form_letter)
  Dir.mkdir("output") unless Dir.exists? "output"
  filename = "output/thanks_#{id}.html"
  
  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

def clean_phone_number(number)
  number.gsub!(/\D/, '')  # remove all NON Digits 
  if number.length == 10
    number 
  elsif number.length == 11 && number[0] == 10
    number = number[1..10]
  else
    number = '0000000000'
  end
end

 def format_date(timestr)
  timestr.gsub(/\s/,' ')  #remove any tabs, returns etc from date
  
  datetime = DateTime.strptime(timestr, '%m/%d/%Y %H:%M')
end

def max_hash(hash)  #returns the key  of the max value
  hash.max_by{ |a,b| b}[0]
end
  
puts "Event Manager initialized!"  

template_letter = File.read "form_letter.html.erb"
erb_template = ERB.new template_letter

days={}
hours={}
contents = CSV.open "event_attendees.csv", headers: true, header_converters: :symbol
contents.each do |row|
  id = row[0]
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])
  phone_number = clean_phone_number(row[:homephone])
  legislators = legislators_by_zipcode(zipcode)
  form_letter = erb_template.result(binding)
  save_thank_you_letters(id,form_letter)
  datetime = format_date(row[:regdate])
  hour = datetime.hour
  if hours[hour].nil?
    hours[hour]=1 
  else 
     hours[hour]+=1
  end
  
  day = datetime.wday
  if days[day].nil?
    days[day]=1 
  else 
     days[day]+=1
  end
  
  
end

target_hour = max_hash(hours)
target_day = max_hash(days)
puts "Your ads should be targeted on day #{target_day} and on hour #{target_hour}"

  



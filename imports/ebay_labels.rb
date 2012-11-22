require 'rubygems'
require 'mechanize'
require 'open-uri'

#attr_accessor :username
#attr_writer :password
#attr_reader :agent, :logged_in, :last_login_time

def search_label(label)
  label.search("span.odc_leftspan").each do |line|
    a =  line.children[0].children.text rescue nil
    b =  line.children[2].text rescue nil
    puts "#{a } co to robi #{b} co to robi"
  end
end

@username = 'bitspudlo_com'
@password = 'w05h0551e'
home = 'http://ebay.com'
@agent = Mechanize.new
home_page = @agent.get(home)
sign_in_link = home_page.link_with( :text => 'Sign in' )
login_page = sign_in_link.click

login_form = login_page.form_with( :name => 'SignInForm')
login_form.userid = @username
login_form.pass = @password
login_response =  login_form.submit
@logged_in = login_response.search('form#SignInForm').empty?
#selling_page = login_response.link_with( :text => 'All selling' ).click
main = login_response.link_with( :text => 'Continue').click
selling = main.link_with( :text => 'Sold' ).click
sold = selling.link_with( :text => /Awaiting Shipment/).click

sold.links_with( :text => 'Print shipping label').each do |link|
  label = link.click
  search_label(label)
  label.search("//div[@id='ShipToCmptId']//*[@class='shipfromtocomponent-addressDisp']/div[@id='addrrow']/div[@id='addrrow']").each do |row|
    next if row.children.text == ""
    pp line = row.children.text 
    puts 'co to robi'
  end
end



